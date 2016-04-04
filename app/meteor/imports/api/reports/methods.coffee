reduce = require 'lodash/reduce'
chain = require 'lodash/chain'
{ Schedules } = require '/imports/api/schedules'

module.exports = (collection) ->
  upsert: (report) ->
    report = collection.tally(report)

    console.log('[Reports] Upserting', report)

    if collection.findOne(day: report.day)
      collection.update({ day: report.day }, { $set: report })
    else
      collection.insert(report)


  tally: (report) ->
    report.total ||= {}

    report.assignees = report.assignees.map (a) ->
      a.hours ||= {}
      a.patients.newPercentage = 100.0 * a.patients.new / a.patients.total
      a.hours.scheduled = Schedules.methods.getScheduledHours({ userId: a.id, day: report.day })
      a.patients.perHourScheduled = a.patients.total / a.hours.scheduled
      a.patients.newPerHourScheduled = a.patients.new / a.hours.scheduled
      return a

    ax = chain(report.assignees)
      .filter (a) -> a.patients.newPerHourScheduled > 0
      .map (a) -> a.patients.newPerHourScheduled
      .value()
    report.total.patientsNewPerHourScheduled = reduce(ax, ((a, b) -> a + b), 0.0) / ax.length

    report.total.revenue = chain(report.assignees)
      .map (a) -> a.revenue
      .reduce ((a, b) -> a + b), 0.0
      .value()

    report.total.hoursScheduled = chain(report.assignees)
      .map (a) -> a?.hours?.scheduled or 0
      .reduce ((a, b) -> a + b), 0.0
      .value()

    report.total.revenuePerAssignee =
      report.total.revenue / report.assignees.length

    report.total.patients = chain(report.assignees)
      .map (a) -> a.patients.total
      .reduce ((a, b) -> a + b), 0.0
      .value()

    report.total.patientsNew = chain(report.assignees)
      .map (a) -> a.patients.new
      .reduce ((a, b) -> a + b), 0.0
      .value()

    return report