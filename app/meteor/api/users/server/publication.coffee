{ Meteor } = require 'meteor/meteor'
{ Users } = require 'api/users'

module.exports = ->
  Meteor.publish 'users', ->
    return unless @userId

    Users.find {}, fields:
      'username': 1
      'groupId': 1
      'status.online': 1
      'status.idle': 1
      'status.lastActivity': 1
      'status.lastLogin.date': 1
      'status.lastLogin.userAgent': 1
      'status.lastLogin.ipAddr': 1
      'profile.firstName': 1
      'profile.lastName': 1
      'profile.titlePrepend': 1
      'profile.titleAppend': 1
      'profile.gender': 1
      'profile.birthday': 1
      'profile.group': 1
      'profile.employee': 1
      'roles': 1
