@Schedules = new Mongo.Collection('schedules')
Ground.Collection(Schedules)

Schema.Schedules = new SimpleSchema
  userId:
    type: SimpleSchema.RegEx.Id,
    index: 1
    optional: true

  available:
    type: Boolean
    index: 1
    optional: true

  validFrom:
    type: Date
    optional: true

  validUntil:
    type: Date
    optional: true

  schedule:
    type: Array
    maxCount: 7
    optional: true

  'schedule.$':
    type: Object

  'schedule.$.day':
    type: String
    autoform:
      options: _.map(Time.weekdays(), (v, k) -> { label: v.label, value: k })

  'schedule.$.shift':
    type: Array

  'schedule.$.shift.$':
    type: Object
    optional: true

  'schedule.$.shift.$.start.h':
    type: Number
    min: 0
    max: 23

  'schedule.$.shift.$.start.m':
    type: Number
    min: 0
    max: 59
    optional: true

  'schedule.$.shift.$.end.h':
    type: Number
    min: 0
    max: 23
  'schedule.$.shift.$.end.m':
    type: Number
    min: 0
    max: 59
    optional: true

  createdAt:
    type: Date
    autoValue: Util.autoCreatedAt
    optional: true

  createdBy:
    type: String
    autoValue: Util.autoCreatedBy
    optional: true

Meteor.startup ->
  Schedules.attachSchema(Schema.Schedules)