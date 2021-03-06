moment = require 'moment'
{ Meteor } = require 'meteor/meteor'
{ SubsManager } = require 'meteor/meteorhacks:subs-manager'
Helpers = require 'util/helpers'
Time = require 'util/time'
Schema = require './schema'
Appointments = require './collection'

module.exports = new Tabular.Table
  name: 'ResolvedAppointments'
  collection: Appointments
  pub: 'appointmentsTable'
  columns: [
    { data: 'start', title: 'Termin', render: (val) -> moment(val).calendar() }
    { data: 'note', title: 'Notiz' }
    { data: 'privateAppointment', title: 'Privat', render: (val, type, doc) -> doc.privateOrInsurance() }
    { data: 'createdBy', title: 'Eintrag', render: (val) -> Helpers.getShortname(val) }
    { data: 'admittedBy', title: 'Empfang', render: (val) -> Helpers.getShortname(val) }
    { data: 'treatedBy', title: 'Behandlung', render: (val) -> Helpers.getShortname(val) }
    { title: '<i class="fa fa-commenting-o"></i>', tmpl: Meteor.isClient and Template.commentCount }
  ]
  order: [[0, 'desc']]
  sub: new SubsManager()
  extraFields: Schema._firstLevelSchemaKeys
  responsive: true
  autoWidth: false
  stateSave: true
  changeSelector: (selector) ->
    pastAppointments =
      end: { $lt: Time.startOfToday() }
      $or: [ { removed: true }, { removed: null } ]

    resolvedAppointments = { removed: true }
    selector.$or = [ resolvedAppointments, pastAppointments ]
    selector
