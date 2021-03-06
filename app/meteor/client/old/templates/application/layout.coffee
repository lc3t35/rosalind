moment = require 'moment'
{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ TAPi18n } = require 'meteor/tap:i18n'


Template.layout.onCreated ->

  Meteor.call 'customer/get', (e, customer) ->
    console.error(e) if e
    document.title = customer.name

  @autorun =>
    @subscribe('users')
    @subscribe('cache')
    @subscribe('groups')
    @subscribe('tags')
    @subscribe('schedules')
    @subscribe('timesheets')
    @subscribe('inboundCalls')

Template.layout.helpers
  loaded: ->
    true
  locale: ->
    TAPi18n.getLanguage()

UI.registerHelper 'activeClass', (context) ->
  {}

UI.registerHelper 'time', (context, options) ->
  return unless context?
  format = if options.format then options.format else 'HH:mm'
  moment(context).format(format)

UI.registerHelper 'showCount', (context) ->
  return unless context?
  count = Counts.get(context)
  if (count > 0) then count else false

Template.registerHelper 'instance', ->
  Template.instance()
