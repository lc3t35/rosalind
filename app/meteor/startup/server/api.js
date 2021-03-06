import users from 'api/users/server'
import groups from 'api/groups/server'
import search from 'api/search/server'
import patients from 'api/patients/server'
import appointments from 'api/appointments/server'
import cache from 'api/cache/server'
import comments from 'api/comments/server'
import customer from 'api/customer/server'
import events from 'api/events/server'
import importers from 'api/importers/server'
import inboundCalls from 'api/inboundCalls/server'
import jobs from 'api/jobs/server'
import reports from 'api/reports/server'
import roles from 'api/roles/server'
import schedules from 'api/schedules/server'
import system from 'api/system/server'
import tags from 'api/tags/server'
import timesheets from 'api/timesheets/server'

export default function () {
  users()
  groups()
  search()
  patients()
  appointments()
  cache()
  comments()
  customer()
  events()
  importers()
  inboundCalls()
  jobs()
  reports()
  roles()
  schedules()
  system()
  tags()
  timesheets()
}
