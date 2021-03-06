#!/bin/bash

set -e

ANSI_RED="\033[31;1m"
ANSI_RESET="\033[0m"

export COMMIT_HASH="${TRAVIS_COMMIT:-$CIRCLE_SHA1}"
export BUILD_NUMBER="${TRAVIS_JOB_NUMBER:-$CIRCLE_BUILD_NUM}"
export ARTIFACTS_PATH="${CIRCLE_ARTIFACTS:-"/tmp/artifacts"}"
echo "[CI] Build $BUILD_NUMBER of commit ${COMMIT_HASH:0:7}"

export DOCKER_COMPOSE_VERSION=1.5.2
export NPM_VERSION=3.10.8
export PHANTOMJS_VERSION=2.1.1

export ROOT_URL=http://0.0.0.0:3000/

export DISPLAY=:99.0
export NPM_CONFIG_LOGLEVEL=warn
export METEOR_PRETTY_OUTPUT=0
export METEOR_WATCH_FORCE_POLLING=true
export METEOR_WATCH_POLLING_INTERVAL_MS=1800000

retry() {
  local result=0
  local count=1
  while [ $count -le 3 ]; do
    [ $result -ne 0 ] && {
      echo -e "\n${ANSI_RED}The command \"$@\" failed. Retrying, $count of 3.${ANSI_RESET}\n" >&2
    }
    "$@"
    result=$?
    [ $result -eq 0 ] && break
    count=$(($count + 1))
    sleep 1
  done

  [ $count -gt 3 ] && {
    echo -e "\n${ANSI_RED}The command \"$@\" failed 3 times.${ANSI_RESET}\n" >&2
  }

  return $result
}

case "$1" in
  install)
    echo "Setting up CI environment"
    SECONDS=0
    { curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > docker-compose; } &
    npm -g install npm@$NPM_VERSION &

    echo "phantomjs $(phantomjs --version)"
    export PATH=$PWD/phantomjs_bin/phantomjs-$PHANTOMJS_VERSION-linux-x86_64/bin:$PATH
    echo "phantomjs $(phantomjs --version)"
    if [ $(phantomjs --version) != '$PHANTOMJS_VERSION' ]; then
      rm -rf $PWD/phantomjs_bin; mkdir -p $PWD/phantomjs_bin
      wget https://github.com/Medium/phantomjs/releases/download/v$PHANTOMJS_VERSION/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -O $PWD/phantomjs_bin/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2
      tar -xvf $PWD/phantomjs_bin/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -C $PWD/phantomjs_bin
    fi
    echo "phantomjs $(phantomjs --version)"

    curl -Lo travis_after_all.py https://raw.githubusercontent.com/dmakhno/travis_after_all/master/travis_after_all.py &
    wait
    npm set registry https://registry.npmjs.org/
    chmod +x docker-compose && sudo mv docker-compose /usr/local/bin
    npm install -g npm-install-retry
    mkdir -p $ARTIFACTS_PATH

    java -version
    echo "npm $(npm --version)"
    echo "node $(node --version)"

    echo "[CI] Machine environment setup took $SECONDS seconds"

    # Install meteor
    echo "[CI] Installing meteor"
    echo -en "travis_fold:start:meteor\r"
    SECONDS=0

    if [ -d ~/.meteor ]; then sudo ln -s ~/.meteor/meteor /usr/local/bin/meteor; fi

    if [ ! -e $HOME/.meteor/meteor ]; then
      RELEASE=`cat app/meteor/.meteor/release`
      RELEASE="${RELEASE:7}"
      METEOR_INSTALL_URL="https://install.meteor.com/?release=${RELEASE}"
      echo "Installing meteor from $METEOR_INSTALL_URL"
      touch $ARTIFACTS_PATH/meteor_installation.log
      curl -o install_meteor.sh $METEOR_INSTALL_URL
      chmod +x install_meteor.sh
      ./install_meteor.sh &>$ARTIFACTS_PATH/meteor_installation.log
    fi

    echo -en "travis_fold:end:meteor\r"
    echo "[CI] Meteor installation took $SECONDS seconds"

    # Installing npm dependencies
    echo "[CI] Installing dependencies from npm"
    echo -en "travis_fold:start:install_dependencies\r"
    SECONDS=0

    echo "[CI] Installing cucumber npm dependencies"
    cd app/meteor/tests/cucumber
    npm-install-retry --wait 500 --attempts 10 -- --progress=false --depth=0
    cd -

    echo "[CI] Installing meteor npm dependencies"
    cd app/meteor
    npm-install-retry --wait 500 --attempts 10 -- --progress=false --depth=0
    cd -

    echo -en "travis_fold:end:install_dependencies\r"
    echo "[CI] Dependencies installation from npm took $SECONDS seconds"
    ;;

  test)
    if [ -z "$ROOT_URL" ]; then
      echo "Please set ROOT_URL for running integration tests"
      exit 1
    fi

    # Run unit tests
    echo -en "travis_fold:start:unit_tests\r"
    npm test
    echo -en "travis_fold:end:unit_tests\r"

    # Start environment for acceptance tests
    echo "[CI] Starting environment for acceptance tests"
    echo -en "travis_fold:start:start_meteor\r"
    SECONDS=0
    RETRY=0

    export TEST=true

    echo "[CI] Starting meteor"
    cd app/meteor
    meteor &
    METEOR_PID=$!

    for i in {1..2700}; do
      printf "(%03d) " $i && curl -q "$ROOT_URL" && break;
      if [ "$SECONDS" -ge 900 ]; then
        RETRY=$((RETRY + 1))
        SECONDS=0
        echo "[CI] Warning: Timed out while waiting for meteor to start"
        kill $METEOR_PID
        meteor &
        METEOR_PID=$!
      fi;

      if [ "$RETRY" -ge 3 ]; then
        echo "[CI] Error: Timed out while waiting for meteor to start after $RETRY retries. Failing tests."
        exit 1
      fi;
      sleep 3
    done;
    echo -en "travis_fold:end:start_meteor\r"
    if [ "$RETRY" -ge 1 ]; then
      echo "[CI] Meteor took $SECONDS seconds to start after $RETRY retries"
    else
      echo "[CI] Meteor took $SECONDS seconds to start"
    fi;

    cd -

    # Run acceptance tests
    echo "[CI] Running acceptance tests"
    echo -en "travis_fold:start:acceptance_tests\r"
    SECONDS=0

    export SAUCE_NAME="Rosalind build $BUILD_NUMBER of commit ${COMMIT_HASH:0:6}"
    export SAUCE_TUNNEL_ID=$BUILD_NUMBER
    export BUILD_NUMBER=$BUILD_NUMBER
    retry npm run test:acceptance
    echo -en "travis_fold:end:acceptance_tests\r"
    echo "[CI] Acceptance tests took $SECONDS seconds"
    ;;

  build)
    echo -en "travis_fold:start:build\r"
    cd production/
    chmod +x prepare.sh
    ./prepare.sh
    retry ./build.sh
    echo -en "travis_fold:end:build\r"

    echo -en "travis_fold:start:image\r"
    retry ./image.sh
    echo -en "travis_fold:end:image\r"

    echo -en "travis_fold:start:push\r"
    retry ./push.sh
    echo -en "travis_fold:end:push\r"

    echo "** Done!"

    ;;

  after_success)
    python travis_after_all.py
    export $(cat .to_export_back) > /dev/null 2>&1
    if [ "$BUILD_LEADER" = "YES" ]; then
      if [ "$BUILD_AGGREGATE_STATUS" = "others_succeeded" ]; then
        echo "** All jobs succeeded!"
        chmod +x production/deploy.sh && production/deploy.sh
      else
        echo "** Some jobs failed"
      fi
    fi

    ;;

  after_failure)
    python travis_after_all.py
    export $(cat .to_export_back) > /dev/null 2>&1
    if [ "$BUILD_LEADER" = "YES" ]; then
      if [ "$BUILD_AGGREGATE_STATUS" = "others_failed" ]; then
        echo "** All jobs failed"
      else
        echo "** Some jobs failed"
      fi
    fi

    ;;

  *)
    echo "Usage: $0 (test|build) -- unknown command '$1'"
    exit 1
esac
