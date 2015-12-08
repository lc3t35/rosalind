Meteor.startup ->
  Appointments.permit(['insert', 'update', 'remove']).ifHasRole('admin').apply()
  Appointments.permit(['insert', 'update']).ifHasRole('appointments').apply()
