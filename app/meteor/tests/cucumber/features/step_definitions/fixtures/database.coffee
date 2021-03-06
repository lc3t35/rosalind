module.exports =
  reset: ->
    server.execute ->
      if process.env.NODE_ENV isnt 'development'
        throw new Error '[Fixtures] resetDatabase is only allowed in development. Something has gone wrong.'
      else
        Package['xolvio:cleaner'].resetDatabase({ excludedCollections: [
          'events'
          '__kdconfig'
          '__kdtimeevents'
          '__kdtraces'
        ] })
