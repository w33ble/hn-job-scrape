resolve = require('url').resolve
debug = require('debug') 'worker'
rDebug = require('debug') 'router'
sjs = require 'scraperjs'
async = require 'async'
_ = require 'lodash'
low = require 'lowdb'
db = low 'data.json',
  autosave: false

list_scraper = require './lib/list_scraper'
item_scraper = require './lib/item_scraper'

router = new sjs.Router({
  # firstMatch: true
})

baseUrl = 'https://news.ycombinator.com'

routes = []
addRoute = (path) ->
  return if not path
  rDebug ['adding route', baseUrl, path].join(' ')
  routes.push resolve(baseUrl, path)

# parse article list
router.on 'https?://news.ycombinator.com/submitted\\?id=:submitter'
.use list_scraper

# # parse post
router.on 'https?://news.ycombinator.com/item\\?id=:itemId'
.use item_scraper

router.otherwise (url) ->
  rDebug '%s was not routed', url

addRoute 'submitted?id=whoishiring'

async.whilst ->
    rDebug 'routes to process %d', routes.length
    routes.length > 0
  , (cb) ->

    route = routes.shift()
    # don't re-process routes
    if db('links').indexOf(route) isnt -1
      rDebug 'skipping route %s, %d remaining', route, routes.length
      return cb()

    rDebug 'loading route %s, %d remaining', route, routes.length
    router.route route, (success, item) ->
      return cb() if !success or !item

      switch item.type
        when 'submission'
          if !item.id
            console.error 'MISSING ID: %s (%s)', item.title, route
            return cb()

          debug '(%d) %s - %d comments', item.id, item.title, item.comments.length
          db('links').push route
          db('submissions').push _.omit(item, 'comments')
          _.each item.comments, (comment, i) ->
            db('comments').push _.extend {
              submission_id: item.id
              id: [item.id, i].join '-'
            }, comment
          db.save()
          cb()

        when 'links'
          item.links.forEach (link) ->
            rDebug 'adding to queue: %s', link.title
            addRoute link.link
          cb()

        else
          debug 'unknown item type: %s', item.type
          cb()

  , (err) ->
    console.error err if err
    debug 'saving db...'
    db.save()
    console.log 'scraping completed!'
