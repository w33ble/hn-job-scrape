debug = require('debug') 'scraper'
sjs = require 'scraperjs'

types =
  static: sjs.StaticScraper
  dynamic: sjs.DynamicScraper

module.exports = (type='static') ->
  debug ['creating new', type, 'scraper'].join(' ')
  types[type].create().onStatusCode (statusCode, utils) ->
    debug 'status code ' + statusCode
    if (statusCode isnt 200)
      utils.stop()
