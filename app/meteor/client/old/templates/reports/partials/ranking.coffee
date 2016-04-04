Template.ranking.helpers
  assigneesWithIndex: ->
    @assignees.map (a, index) ->
      a.index = index + 1
      return a

  assignee: ->
    Meteor.users.findOne(@id)

  hasNewPatients: ->
    @patients.new and @patients.new > 0

Template.ranking.onCreated ->
  $('[data-toggle="tooltip"]').tooltip()