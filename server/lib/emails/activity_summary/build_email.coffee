CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
promises_ = __.require 'lib', 'promises'
host = CONFIG.fullPublicHost()
{ i18n } = require '../i18n/i18n'
{ contactAddress } = CONFIG
{ newsKey, didYouKnowKey } = CONFIG.activitySummary
# keep in sync with the nextSummary view in the user design_docs
# and defaultPeriodicity in the client's notifications_settings
defaultPeriodicity = 20

user_ = __.require 'lib', 'user/user'
relations_ = __.require 'controllers', 'relations/lib/queries'
groups_ = __.require 'controllers', 'groups/lib/groups'
notifs_ = __.require 'lib', 'notifications'
transactions_ = __.require 'controllers', 'transactions/lib/transactions'

getLastFriendsBooks = require './last_friends_books'
getLastNearbyPublicBooks = require './last_nearby_books'

module.exports = (user)->
  getEmailData user
  .then spreadEmailData.bind(null, user)

getEmailData = (user)->
  { _id:userId, lastSummary } = user
  promises_.props
    # pending friends requests
    friendsRequests: relations_.pendingFriendsRequestsCount userId
    # pending group invitation
    groupInvitations: groups_.pendingGroupInvitationsCount userId
    groupRequests: groups_.pendingGroupRequestsCount userId
    # unread notifications
    unreadNotifications: notifs_.unreadCount userId
    # waiting transaction
    activeTransactions: transactions_.activeTransactions userId
    # new books in your network: preview + count for others 'X more...'
    lastFriendsBooks: getLastFriendsBooks userId, lastSummary
    # new books nearby
    lastNearbyPublicBooks: getLastNearbyPublicBooks user, lastSummary

    # FUTURE TODO
    # waiting transaction
      # where you have an action to do
      # where you have been waiting for the other's action for long now
    # new users nearby
    # new users in groups

spreadEmailData = (user, results)->
  {
    friendsRequests,
    groupInvitations,
    groupRequests,
    unreadNotifications,
    activeTransactions,
    lastFriendsBooks,
    lastNearbyPublicBooks
  } = results

  { email, language, summaryPeriodicity } = user
  lang = _.shortLang language

  countTotal = friendsRequests + groupInvitations + groupRequests + unreadNotifications + activeTransactions + lastFriendsBooks.highlighted.length

  periodicity = user.summaryPeriodicity or defaultPeriodicity

  news = newsData user

  if news.display is false and countTotal is 0
    throw promises_.skip 'empty activity summary', user._id

  # attach the lang to make accessible for the last_books partial
  lastFriendsBooks.lang = lang
  lastNearbyPublicBooks.lang = lang

  return data =
    to: email
    subject: i18n lang, 'activity_summary_title'
    template: 'activity_summary'
    context:
      user: user
      lang: lang
      meta:
        host: host
        periodicity: periodicity
        settingsHref: host + '/settings/notifications'
        contactAddress: contactAddress
      friendsRequests: counter friendsRequests, '/network/friends'
      groupInvitations: counter groupInvitations, '/network/groups'
      groupRequests: counter groupRequests, '/network/groups'
      unreadNotifications: counter unreadNotifications, '/notifications'
      activeTransactions: counter activeTransactions, '/transactions'
      lastFriendsBooks: lastFriendsBooks
      lastNearbyPublicBooks: lastNearbyPublicBooks
      news: news
      didYouKnowKey: didYouKnowKey
      hasActivities: countTotal > 0

counter = (count, path)->
  display: count > 0
  smart_count: count
  href: host + path

newsData = (user)->
  { lastNews } = user
  if lastNews isnt newsKey
    display: true
    key: newsKey
  else
    display: false
