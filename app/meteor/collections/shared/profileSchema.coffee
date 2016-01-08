Schema.Contact = new SimpleSchema
  value:
    type: String

  channel:
    allowedValues: ['Phone', 'Email']
    type: String

  order:
    type: Number
    optional: true

  note:
    type: String
    optional: true

Schema.Address = new SimpleSchema
  line1:
    type: String
    optional: true

  line2:
    type: String
    optional: true

  postalCode:
    type: String
    optional: true

  locality:
    type: String
    optional: true

  country:
    type: String
    optional: true

Schema.Profile = new SimpleSchema
  firstName:
    type: String
    optional: true
    index: 1

  lastName:
    type: String
    optional: true
    index: 1

  titlePrepend:
    type: String
    optional: true

  titleAppend:
    type: String
    optional: true

  birthday:
    type: Date
    optional: true
    index: 1

  gender:
    type: String
    allowedValues: ['Male', 'Female']
    optional: true

  employee:
    type: Boolean
    optional: true
    index: 1

  contacts:
    type: [Schema.Contact]
    optional: true

  address:
    type: Schema.Address
    optional: true