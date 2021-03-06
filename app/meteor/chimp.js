var requiredEnv = [
  'ROOT_URL',
  'BROWSER',
  'OS',
  'SAUCE_USERNAME',
  'SAUCE_ACCESS_KEY',
  'SAUCE_HOST',
  'SAUCE_PORT'
]

requiredEnv.forEach(function (v) {
  if (!process.env[v]) {
    console.error('Please set env variables', requiredEnv)
    console.error('Missing env variable: ' + v)
    process.exit(1)
  }
})

var browser = {
  name: process.env.BROWSER.split(':')[0],
  version: process.env.BROWSER.split(':')[1],
  resolution: process.env.SCREEN_RESOLUTION || '1280x1024'
}

var os = {
  long: process.env.OS,
  short: {
    'Windows 10': 'WIN10',
    'Windows 8.1': 'WIN8',
    'Windows 8': 'WIN8',
    'Windows 7': 'VISTA',
    'Windows XP': 'XP'
  }[process.env.OS]
}

var buildName = process.env.SAUCE_NAME || 'Test run in development mode'

console.log('** OS:', process.env.OS)
console.log('** Browser:', browser.name, browser.version)
console.log('** Worker:', process.env.SAUCE_TUNNEL_ID)

module.exports = {
  watch: process.env.WATCH || false,

  path: './tests/cucumber/features/',
  ddp: process.env.ROOT_URL,

  compiler: 'coffee:coffee-script/register',

  browser: browser.name.toLowerCase(),
  platform: os.short,

  name: buildName,
  host: process.env.SAUCE_HOST,
  port: process.env.SAUCE_PORT,
  user: process.env.SAUCE_USERNAME,
  key: process.env.SAUCE_ACCESS_KEY,

  noSessionReuse: true,

  webdriverio: {
    desiredCapabilities: {
      browserName: browser.name,
      version: browser.version,
      platform: os.long,
      screenResolution: browser.resolution,
      'tunnel-identifier': process.env.SAUCE_TUNNEL_ID,
      name: buildName,
      build: process.env.BUILD_NUMBER,
      public: true,
      after: function () {
        browser.end()
      }
    },
    services: ['sauce'],
    user: process.env.SAUCE_USERNAME,
    key: process.env.SAUCE_ACCESS_KEY,
    host: process.env.SAUCE_HOST,
    port: process.env.SAUCE_PORT,
    waitforTimeout: 30000,
    waitforInterval: 250
  }
}
