import { Meteor } from 'meteor/meteor'
import { ValidatedMethod } from 'meteor/mdg:validated-method'
import { SimpleSchema } from 'meteor/aldeed:simple-schema'
import { Events } from 'api/events'

export const upsert = ({ Schedules, Users }) => {
  return new ValidatedMethod({
    name: 'schedules/upsert',

    validate: new SimpleSchema({
      schedule: { type: Object, blackbox: true },
      quiet: { type: Boolean, optional: true }
    }).validator(),

    run ({ schedule, quiet }) {
      if (this.connection && !this.userId) {
        throw new Meteor.Error(403, 'Not authorized')
      }

      let selector = {}
      if (schedule.start) { selector.start = schedule.start }
      if (schedule.end) { selector.end = schedule.end }
      if (schedule.userId) { selector.userId = schedule.userId }
      if (schedule.type) { selector.type = schedule.type }

      const existingSchedule = Schedules.findOne(selector)

      if (existingSchedule) {
        Schedules.update({ _id: existingSchedule._id }, { $set: schedule })
        if (!quiet) { Events.post('schedules/upsert', { scheduleId: existingSchedule._id }) }
        return existingSchedule._id
      } else {
        try {
          const scheduleId = Schedules.insert(schedule, (err) => {
            if (err) { throw err }
            if (!quiet) { Events.post('schedules/insert', { scheduleId }) }
          })
          return scheduleId
        } catch (e) {
          console.error('[Schedules] Insert failed with error', e, 'of schedule', schedule)
        }
      }
    }
  })
}
