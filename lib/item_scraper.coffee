debug = require('debug') 'scraper'
sjs = require 'scraperjs'
scraper = require './scraper'

module.exports = scraper()
  .scrape ($) ->
    debug 'scraper has results'
    {
      title: $('.title a').first().text()
      content: $('table').eq(2).find('tr').eq(3).find('td').eq(1).html()
      comments: $('.default').map( (comment) ->
        {
          comment: $(this).find('.comment').first().html()
          author: $(this).find('.comhead a').first().text()
          posted: $(this).find('.comhead a').eq(1).html()
          links: $(this).find('.comment a').map( ->
            return $(this).attr('href')
          ).toArray()

        }
      ).toArray()
    }
  , (item, utils) ->
    debug ['found', item.comments.length, 'comments on page'].join(' ')
    if utils.params.itemId?
      item.id = utils.params.itemId
    return item
