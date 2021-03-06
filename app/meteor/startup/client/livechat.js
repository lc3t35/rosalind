/* global Smooch */
import scriptjs from 'scriptjs'
import { Meteor } from 'meteor/meteor'
import { Tracker } from 'meteor/tracker'
import { process as server } from 'meteor/clinical:env'
import { TAPi18n } from 'meteor/tap:i18n'
import { Groups } from 'api/groups'

const getTranslation = () => {
  const keys = [ 'headerText', 'inputPlaceholder', 'sendButtonText',
  'introductionText', 'introAppText', 'settingsText',
  'settingsReadOnlyText', 'settingsInputPlaceholder',
  'settingsSaveButtonText', 'settingsHeaderText', 'settingsNotificationText',
  'actionPostbackError', 'messageError', 'messageIndicatorTitleSingular',
  'messageIndicatorTitlePlural' ]

  let translation = {}

  keys.map((key) => {
    translation[key] = TAPi18n.__(['livechat', key].join('.'), {}, 'de')
  })

  return translation
}

export default () => {
  if (server.env.SMOOCH_APP_TOKEN && !server.env.TEST) {
    scriptjs('https://cdn.smooch.io/smooch.min.js', () => {
      Smooch.init({
        appToken: server.env.SMOOCH_APP_TOKEN,
        imageUploadEnabled: false,
        emailCaptureEnabled: true,
        customText: getTranslation()
      }).then(() => {
        let currentUserId = null
        Tracker.autorun(() => {
          const user = Meteor.user()
          if (user) {
            if (!currentUserId) {
              const env = server.env.NODE_ENV.toUpperCase()
              const smoochUserId = `USER-${user._id}${env === 'PRODUCTION' ? '' : `-${env}`}`
              const group = user.groupId && Groups.findOne({ _id: user.groupId })
              Smooch.login(smoochUserId, {
                givenName: user.profile.firstName,
                surname: user.profile.lastName,
                email: user.email,
                properties: {
                  username: user.username,
                  fullNameWithTitle: user.fullNameWithTitle(),
                  employee: user.profile.employee,
                  group: group && group,
                  roles: user.getRoles()
                }
              }).then(() => {
                console.log('[Livechat] Logged in')
              }).catch((e) => {
                console.error('[Livechat] Failed to login', e)
              })
            }
            currentUserId = user._id
          } else {
            currentUserId = null
            Smooch.logout().then(() => {
              console.log('[Livechat] Logged out')
            }).catch((e) => {
              console.error('[Livechat] Failed to logout', e)
            })
          }
        })
      }).then(() => {
        console.log('[Livechat] Initialized')
      }).catch((e) => {
        console.error('[Livechat] Failed to initialize', e)
      })
    })
  }
}
