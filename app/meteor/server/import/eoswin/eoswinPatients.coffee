Meteor.startup ->
  Job.processJobs 'import', 'eoswinPatients', (job, callback) ->
    job.log('EoswinPatients: Running')

    Import.Adt
      path: job.data.path
      progress: job
      batchSize: 1000
      iterator: (row) ->
        return false unless row.PatId

        contacts = [
          { channel: 'Phone', value: row.Telefon1 }
          { channel: 'Phone', value: row.Telefon2 }
          { channel: 'Email', value: row.EMail }
          { channel: 'Phone', note: 'Fax', value: row.Fax }
        ]

        noContact = [
          'keine nr.', 'keine', 'nein', 'k nr', 'keine nummer',
          'keine vorhanden', 'keine nr', 'k tel', 'k,nr',
          'k tel', 'k a', 'keines', 'kein tel', 'kein telefon'
          'hat keines', 'hat keine', 'kein', 'keinhe', 'keine tele',
          'hat nicht', 'kein nr',
          'keine mailadresse', 'kein mailadresse',
          'no', '#', ',', '-'
        ]

        contacts = _.chain(contacts)
          .filter (c) -> c.value.length > 0
          .map (c, index) ->
            if c.value and _.contains(noContact, c.value.toLowerCase().split('.').join(' ').replace(/\s\s+/g, ' ').trim())
              return null
            else if c.value and c.value.indexOf('@') > 0 and c.value.indexOf('.') > 0
              return { value: c.value, channel: 'Email', order: index + 1 }
            else if c.value.match(/[0-9]/)
              c.order = index + 1
              return c
            else
              contactsNote = 'Kontakt: ' + c.value
              return null
          .filter (c) -> c?
          .value()

        note = []
        note.push(row.Bemerkung) if row.Bemerkung.length > 0
        note.push(row.Bemerkung2) if row.Bemerkung2.length > 0
        note.push(contactsNote) if contactsNote?
        note = note.join('\n\n')

        if row.LandCode.length > 0
          country = switch row.LandCode
            when 'A' then 'AT'
            when 'D' then 'DE'
            when 'DD' then 'DE'
            when 'H' then 'HU'
            when 'GBS' then 'GB'
            when 'E' then 'ES'
            when 'CH' then 'CH'
            else job.log("EoswinPatiens: Unmapped country code: #{row.LandCode}", level: 'warning')


        titlePrepend = row.Titel if row.Titel? and row.Titel.length > 0
        titlePrepend = titlePrepend.split('Dr').join('Dr.').split('Mag').join('Mag.') if titlePrepend and titlePrepend.indexOf('.') is -1

        birthday = moment(row.GebDat, 'YYYYMMDD').toDate() unless row.GebDat is '00000000'
        createdAt = moment(row.AnlDat + row.AnlZeit, 'YYYYMMDDHHMM').toDate() unless row.AnlDat is '00000000'

        patient =
          external:
            eoswin:
              id: row.PatId
          insuranceId: row.VersNr
          note: note
          createdAt: createdAt
          createdBy: job.data.userId
          importedAt: moment().toDate()
          importedBy: job.data.userId
          externalUpdatedAt: moment(row.LastDatum + row.LastZeit, 'YYYYMMDDHHMM').toDate() unless row.LastDatum is '00000000'
          externalUpdatedBy: row.LastUser
          profile:
            firstName: row.Vorname
            lastName: row.Zuname
            titlePrepend: titlePrepend
            gender: row.Geschl.replace('W', 'Female').replace('M', 'Male') if row.Geschl?
            birthday: birthday
            contacts: contacts
            address:
              line1: row.Strasse
              postalCode: row.Plz
              locality: row.Ort
              country: country

        return patient

      bulk: (records) ->
        bulk = Patients.rawCollection().initializeUnorderedBulkOp()

        for i in [0...records.length]
          record = records[i]
          record._id = Random.id()
          bulk.insert(record)

        if Meteor.wrapAsync(bulk.execute, bulk)().ok is not 1
          job.log("EoswinPatients: Bulk execute error: #{JSON.stringify(d)}")
          job.fail()

    job.done() and callback()