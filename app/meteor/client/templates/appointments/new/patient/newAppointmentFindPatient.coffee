getSelected = ->
  selected = $('.selected-result')
  if selected.length is 0
    $('.search-results li').last().addClass('selected-result')
    selected = $('.selected-result')
  return selected

selectOption = (final) ->
  selected = $('.selected-result')
  _id = selected.data('id')

  if _id
    $('#patient-search-box').val(selected.find('.full-name').text())
    @newAppointment.set('patient', final)
    @newAppointment.set('patientId', _id)

  else
    console.log('creating new patient')
    @newAppointment.set('patient', final)
    @newAppointment.set('patientName', $('#patient-search-box').val())

Template.newAppointmentFindPatient.events
  'keyup #patient-search-box': (->
    handler = (e) ->
      queryString = $(e.target).val().trim()
      PatientsSearch.search(queryString)
    _.throttle(handler, 100)
  )()

  'keydown #patient-search-box': (e) ->
    if e.keyCode is keyCode.enter
      e.preventDefault()
      if $('.search-results').is(':visible')
        selectOption()
      else
        $('.search-results').show()

    else if e.keyCode is keyCode.up
      e.preventDefault()
      selected = getSelected()
      $('.search-results li').removeClass('selected-result')
      if selected.prev().length is 0
        selected.siblings().last().addClass('selected-result')
      else
        selected.prev().addClass('selected-result')

    else if e.keyCode is keyCode.down
      e.preventDefault()
      selected = getSelected()
      $('.search-results li').removeClass('selected-result')
      if selected.next().length is 0
        selected.siblings().first().addClass('selected-result')
      else
        selected.next().addClass('selected-result')

    else
      $('.search-results').show()

  'mouseover .search-results li': (e) ->
    $('.search-results li').removeClass('selected-result')
    $(e.currentTarget).addClass('selected-result')
    selectOption()

  'click .search-results li': ->
    selectOption()

Template.newAppointmentFindPatient.onCreated = ->
  $('#patient-search-box').focus()

Template.newAppointmentFindPatient.helpers
  currentStep: ->
    if not newAppointment.get('patient')
      'box-info'
    else
      'box-default'

  patientId: ->
    newAppointment.get('patientId')

filterFields = [
  'profile.titlePrepend'
  'profile.titleAppend'
  'profile.firstName'
  'profile.lastName'
]

@PatientsSearch = new SearchSource 'patients', filterFields,
  keepHistory: 1000 * 60 * 30
  localSearch: false

keyCode =
  enter: 13
  up: 38
  down: 40
