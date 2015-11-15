UI.registerHelper 'loaded', ->
  Session.get('loaded')

UI.registerHelper 'activeClass', (context) ->
  { class: 'active' } if (context is Router.current().route.path())

UI.registerHelper 'time', (context, options) ->
  return unless context?
  format = if options.format then options.format else 'HH:mm'
  moment(context).format(format)

UI.registerHelper 'showCount', (context) ->
  return unless context?
  count = Mongo.Collection.get(context) and Mongo.Collection.get(context).find({}).count()
  if (count > 0) then count else false