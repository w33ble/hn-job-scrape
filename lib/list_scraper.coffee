debug = require('debug') 'scraper'
scraper = require './scraper'
sjs = require 'scraperjs'

module.exports = scraper()
  .scrape ($) ->
    debug 'scraper has results'
    $('.title a').map ->
      id: $(this).attr('href').match(/id=([1-9].+)?/)[1]
      title: $(this).text()
      link: $(this).attr('href')
  , (items, utils) ->
    debug ['found', items.length, 'items on page'].join(' ')
    if utils.params.submitter?
      debug 'attaching submitter ' + utils.submitter
      items = items.map (item) ->
        item.submitter = utils.submitter
    return items
