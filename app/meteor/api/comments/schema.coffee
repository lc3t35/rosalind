{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
Auto = require 'util/schema/auto'

module.exports = new SimpleSchema
  docId:
    type: String
    regEx: SimpleSchema.RegEx.Id
    index: 1

  body:
    type: String

  createdBy:
    type: String
    regEx: SimpleSchema.RegEx.Id
    autoValue: Auto.createdBy

  createdAt:
    type: Date
    autoValue: Auto.createdAt
    index: 1
