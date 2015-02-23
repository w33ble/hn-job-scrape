resolve = require('url').resolve
rDebug = require('debug') 'router'
debug = require('debug') 'worker'
sjs = require 'scraperjs'
async = require 'async'
_ = require 'lodash'

list_scraper = require './lib/list_scraper'
item_scraper = require './lib/item_scraper'

router = new sjs.Router({
  # firstMatch: true
})

baseUrl = 'https://news.ycombinator.com'

routes = []
addRoute = (path) ->
  return if not path
  debug ['adding route', baseUrl, path].join(' ')
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

console.error 'not ready to be run'
return

async.whilst ->
    rDebug 'routes to process %d', routes.length
    routes.length > 0
  , (cb) ->
    route = routes.shift()
    rDebug 'loading route %s', route
    router.route route, (success, items) ->
      return cb() if !success or !items

      items.each () ->
        debug 'adding to queue: %s', this.title
        addRoute this.link
      cb()
  , (err) ->
    if (err)
      console.error err
    console.log 'all done'
