CONFIG = require 'config'
__ = CONFIG.root
_ = __.require 'builders', 'utils'
error_ = __.require 'lib', 'error/error'
passport_ = __.require 'lib', 'passport/passport'

exports.signup = (req, res)->
  {strategy} = req.body
  next = LoggedIn(res)
  switch strategy
    when 'local' then passport_.authenticate.localSignup(req, res, next)
    else error_.bundle res, "unknown signup strategy: #{strategy}", 400

exports.login = (req, res)->
  {strategy} = req.body
  next = LoggedIn(res)
  switch strategy
    when 'local' then passport_.authenticate.localLogin(req, res, next)
    when 'browserid' then passport_.authenticate.browserid(req, res, next)
    else error_.bundle res, "unknown login strategy: #{strategy}", 400

LoggedIn = (res)->
  loggedIn = ->
    res.cookie 'loggedIn', true
    res.send 'ok'

exports.logout = (req, res, next) ->
  _.log req.session, "logout request - #{new Date()}"
  _.log req.headers, 'headers'
  res.clearCookie 'loggedIn'
  req.logout()
  res.redirect '/'