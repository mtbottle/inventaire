__ = require('config').root
_ = __.require 'builders', 'utils'
error_ = __.require 'lib', 'error/error'
wdq = __.require 'data','wikidata/wdq'
thumb = __.require 'data','commons/thumb'


module.exports.get = (req, res, next)->
  {api, query, pid, qid} = req.query
  switch api
    when 'wdq' then return wdq(res, query, pid, qid)
    when 'commons-thumb' then return thumb(req, res)
    else error_.bundle res, 'unknown data provider', 400, api
