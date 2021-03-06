{ Meteor } = require 'meteor/meteor'
{ check } = require 'meteor/check'
{ Roles } = require 'meteor/alanning:roles'
{ Events } = require 'api/events'

module.exports = ->
  Meteor.publish 'events', (options) ->
    return unless @userId and Roles.userIsInRole(@userId, ['events', 'admin'], Roles.GLOBAL_GROUP)
    check options, Match.Optional
      date: Match.Optional(Date)

    Events.find {},
      limit: 20
      sort: { createdAt: -1 }
