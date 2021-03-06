__ = require('config').universalPath
_ = __.require 'builders', 'utils'
error_ = __.require 'lib', 'error/error'
wdq = __.require 'data','wikidata/wdq'
wdQuery = __.require 'data','wikidata/query'
thumb = __.require 'data','commons/thumb'
wikipediaExtract = __.require 'data','wikipedia/extract'
enWikipediaImage = __.require 'data','wikipedia/image'
openLibraryCover = __.require 'data','openlibrary/cover'

module.exports.get = (req, res, next)->
  { api } = req.query
  switch api
    when 'wdq' then return wdq req, res
    when 'wd-query' then return wdQuery req, res
    when 'commons-thumb' then return thumb req, res
    when 'wp-extract' then return wikipediaExtract req, res
    when 'openlibrary-cover' then return openLibraryCover req, res
    when 'en-wikipedia-image' then return enWikipediaImage req, res
    else error_.bundle res, 'unknown data provider', 400, req.query
