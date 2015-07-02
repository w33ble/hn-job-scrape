debug = require('debug') 'scraper'
sjs = require 'scraperjs'
scraper = require './scraper'

getDate = (text) ->
  return null if !text
  d = new Date()
  days = text.split('days ago')[0].trim()
  d.setDate d.getDate() - days
  month = d.getMonth()
  year = d.getFullYear()
  return [
    year
    ("00" + ++month).substr(-2,2)
    # ("00" + d.getDate()).substr(-2,2)
  ].join('-')


module.exports = scraper()
  .scrape ($) ->
    title = $('.title a').first().text()

    return {
      type: 'submission'
      title: title
      content: $('table').eq(2).find('tr').eq(3).find('td').eq(1).html()
      comments: $('.default').map( (comment) ->
        posted = $(this).find('.comhead a').eq(1).text()
        commentHtml = $(this).find('.comment').first().html()

        return {
          title: title
          author: $(this).find('.comhead a').first().text()
          posted: posted
          date: getDate(posted)
          commentHtml: commentHtml
          commentCleaned: commentHtml.replace(/<p>/gm, '\n\n').replace(/<(?:.|\n)*?>/gm, '').trim()
          comment: $(this).find('.comment').first().text()
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
