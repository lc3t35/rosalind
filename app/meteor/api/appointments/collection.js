import { Meteor } from 'meteor/meteor'
import { Mongo } from 'meteor/mongo'
import helpers from './helpers'
import methods from './methods'
import actions from './actions'
import Schema from './schema'

let Appointments = new Mongo.Collection('appointments')
Appointments.attachSchema(Schema)
Appointments.attachBehaviour('softRemovable')
Appointments.helpers({ collection: () => Appointments })
Appointments.helpers(helpers)
Appointments.methods = methods({ Appointments })
Appointments.actions = actions({ Appointments })

if (Meteor.isServer) {
  Meteor.startup(() => {
    Appointments._ensureIndex({ lockedAt: 1 }, { expireAfterSeconds: 60 * 10 })
  })
}

export default Appointments
