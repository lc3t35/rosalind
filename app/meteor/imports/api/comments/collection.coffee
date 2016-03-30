{ Mongo } = require 'meteor/mongo'
Schema = require './schema'

Comments = new Mongo.Collection('Comments')
Comments.attachSchema(Schema)
Comments.attachBehaviour('softRemovable')
Comments.helpers({ collection: -> Comments })

module.exports = Comments
