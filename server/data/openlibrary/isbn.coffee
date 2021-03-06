__ = require('config').universalPath
_ = __.require 'builders', 'utils'
error_ = __.require 'lib', 'error/error'
cache_ = __.require 'lib', 'cache'
promises_ = __.require 'lib', 'promises'
{ getUrlFromKey, isbnUrl } = require './api'
{ oneYear } =  __.require 'lib', 'times'
formatBook = require './format_book'

module.exports = (isbn, maxAge=oneYear)->
  key = "ol:#{isbn}"
  cache_.get key, requestBook.bind(null, isbn), maxAge

requestBook = (isbn)->
  getBooksDataByIsbn isbn
  .then parseBookData.bind(null, isbn)
  .catch (err)->
    unless err.status is 404 then throw err
    _.warn isbn, err.message
    return


getBooksDataByIsbn = (isbn)->
  promises_.get isbnUrl(isbn)
  .then _.property('key')
  .then _.Log('key')
  .then (key)->
    if key? then promises_.get getUrlFromKey(key)
    else throw error_.new 'openlibrary: book not found', 404, isbn

parseBookData = (isbn, bookData)->
  bookData.isbn = isbn
  return formatBook bookData
