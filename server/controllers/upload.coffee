CONFIG = require 'config'
formidable = require 'formidable'
client = require '../helpers/knox-client'
Q = require 'q'


module.exports.post = (req, res, next)->
  form = new formidable.IncomingForm()
  form.parse req, (err, fields, files) ->
    _.logGreen {
        fields: fields
        files: files
        }, 'form parse'
    if err
      _.log err, 'err'
      res.json 500, {status: err}
    else
      promises = []
      for k,file of files

        # /tmp/ path
        src = file.path
        type = file.type

        promise = client.putImage(src, type)
        .then (response)-> _.logYellow response.req.url, 'url?'

        promises.push promise

      Q.all promises
      .then (urls)->
        _.logYellow urls, 'urls'
        ownedUrls = urls.map extractOwnedUrl
        _.logYellow ownedUrls, 'ownedUrls'
        res.json 200, ownedUrls
      .fail (err)->
        _.logRed err, 'putImage err'
        res.json 500, {status: err}

module.exports.del = (req, res, next)->
  filenames = req.body.urls
  _.logGreen filenames, 'filenames?'
  client.deleteImages(filenames)
  .then (resp)->
    _.logYellow resp.statusCode, 'delete statusCode'
    if resp.statusCode is 200
      res.json 200, {status: 'OK'}
    else throw {status: 'FAILED'}
  .fail (err)->
    res.json 500, err


extractOwnedUrl = (url)->
  parts = url.split CONFIG.aws.bucket
  path = parts.last()
  return "//#{CONFIG.aws.bucket}#{path}"