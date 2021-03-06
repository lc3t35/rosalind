hotkeys = require 'startup/client/hotkeys'

Template.hotkeys.helpers
  hotkeys: ->
    hotkeys()[@]

  groups: ->
    Object.keys(hotkeys())

  keys: ->
    if typeof @key is 'object'
      @key
    else
      @key.split(' ')

  hotkeyName: ->
    TAPi18n.__('hotkeys.' + @name)
