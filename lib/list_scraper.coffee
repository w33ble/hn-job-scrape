debug = require('debug') 'scraper'
scraper = require './scraper'
sjs = require 'scraperjs'

module.exports = scraper()
  .scrape ($) ->
    debug 'scraper has results'
    return {
      type: 'links'
      links: $('.title a').map ->
        id: $(this).attr('href').match(/id=([1-9].+)?/)[1]
        title: $(this).text()
        link: $(this).attr('href')
    }

  , (item, utils) ->
    debug ['found', item.links.length, 'links on page'].join(' ')
    if utils.params.submitter?
      debug 'attaching submitter ' + utils.submitter
      item.links = item.links.map (link) ->
        link.submitter = utils.params.submitter
    return item
