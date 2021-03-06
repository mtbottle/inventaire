module.exports = attributes = {}

# attributes that can be send to the owner
attributes.ownerSafe = [
  '_id'
  '_rev'
  'username'
  'email'
  'picture'
  'language'
  'creationStrategy'
  'hasPassword'
  'validEmail'
  'bio'
  'settings'
  'position'
  'summaryPeriodicity'
]

attributes.public = [
  '_id'
  'username'
  'picture'
  'bio'
  'position'
]

# attributes that need availability check before update
attributes.concurrencial = [
  'username'
  'email'
]

# attributes that can be changed with a simple validity check
attributes.updatable = [
  'picture'
  'language'
  'bio'
  'settings'
  'position'
  'summaryPeriodicity'
]


# attributes that are kept after a user deleted her account
attributes.critical = [
  '_id'
  '_rev'
  'username'
]

# attributes to keep in documents where a stakeholder might loose
# access to those data
# ex: in a transaction, when the user was deleted
# The _id is already recorded by a transaction
# thus its absence here as long as only transactions doc uses snaphshot
attributes.snapshot = [
 'username'
 'picture'
]
