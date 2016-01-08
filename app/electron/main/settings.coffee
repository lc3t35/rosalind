fs = require('fs')
path = require('path')
_ = require('lodash')
electron = require('app')
ipc = require('electron').ipcMain
logger = require('./logger')

settingsPath = path.join(electron.getPath('userData'), 'RosalindSettings.json')

defaultSettings =
  bdt:
    watch: '.'
    delete: true

settings = null

if fs.existsSync(settingsPath)
  logger.info('[Settings] Loading existing settings from', settingsPath)
  try
    persistedSettings = JSON.parse(fs.readFileSync(settingsPath, encoding: 'utf8'))
    if _.isEqual(settings, defaultSettings)
      settings = persistedSettings
    else
      settings = _.merge(defaultSettings, persistedSettings)
      logger.info('[Settings] Writing updated settings to', settingsPath)
      fs.writeFile settingsPath, JSON.stringify(settings, null, 2), encoding: 'utf8', (err) ->
        logger.error('[Settings] Cannot write updated settings', err) if err?
  catch e
    logger.error('[Settings] Cannot parse settings file', e)

else
  logger.info('[Settings] Writing default settings to', settingsPath)
  fs.writeFile settingsPath, JSON.stringify(defaultSettings, null, 2), encoding: 'utf8', (err) ->
    logger.error('[Settings] Cannot write default settings', err) if err?
  settings = defaultSettings


logger.info('[Settings]', settings)

ipc.on 'settings', (e) ->
  logger.info('[Settings] Requested settings via ipc')
  e.sender.send('settings', settings)


module.exports = settings