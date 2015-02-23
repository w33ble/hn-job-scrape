debug = require('debug') 'scraper'
sjs = require 'scraperjs'

types =
  static: sjs.StaticScraper
  dynamic: sjs.DynamicScraper

module.exports = (type='static') ->
  debug ['creating new', type, 'scraper'].join(' ')
  types[type].create().onStatusCode (statusCode, utils) ->
    if (statusCode isnt 200)
      debug 'status code ' + statusCode
      utils.stop()
