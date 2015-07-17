resolve = require('url').resolve
debug = require('debug')
debuggers =
  worker: debug('worker')
  router: debug('router')
sjs = require 'scraperjs'
async = require 'async'
_ = require 'lodash'
low = require 'lowdb'
db = low 'data.json',
  autosave: false

list_scraper = require './lib/list_scraper'
item_scraper = require './lib/item_scraper'

# pre-process the database
require('./lib/pre_process') db

router = new sjs.Router({
  # firstMatch: true
})

baseUrl = 'https://news.ycombinator.com'

routes = []
addRoute = (path) ->
  return if not path
  debuggers.router ['adding route', baseUrl, path].join(' ')
  routes.push resolve(baseUrl, path)

# parse article list
router.on 'https?://news.ycombinator.com/submitted\\?id=:submitter'
.use list_scraper

# # parse post
router.on 'https?://news.ycombinator.com/item\\?id=:itemId'
.use item_scraper

router.otherwise (url) ->
  debuggers.router '%s was not routed', url

addRoute 'submitted?id=whoishiring'

async.whilst ->
  debuggers.worker 'routes to process %d', routes.length
  routes.length > 0
, (cb) ->
    route = routes.shift()
    # don't re-process routes
    if db('links').indexOf(route) isnt -1
      debuggers.router '-- Skipping route %s, %d remaining', route, routes.length
      return cb()

    debuggers.router '++ Loading route %s, %d remaining', route, routes.length
    router.route route, (success, item) ->
      return cb() if !success or !item

      switch item.type
        when 'submission'
          if !item.id
            console.error 'MISSING ID: %s (%s)', item.title, route
            return cb()

          debuggers.worker '(%d) %s - Adding %d entries', item.id, item.title, item.comments.length
          _.assign item, { url: route }
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
            debuggers.router 'adding link to queue: %s', link.title
            addRoute link.link
          cb()

        else
          debuggers.worker 'unknown item type: %s', item.type
          cb()

  , (err) ->
    console.error err if err
    debuggers.worker 'Saving database'
    db.save()

    console.log '+++ Scraping Completed!'
