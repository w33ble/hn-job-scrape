elasticsearch = require 'elasticsearch'
debug = require('debug') 'worker'
bDebug = require('debug') 'batch'
esDebug = require('debug') 'elasticsearch'
async = require 'async'
low = require 'lowdb'
_ = require 'lodash'
moment = require 'moment'
createMapping = require './lib/create_mapping'

esHost = 'localhost:9200'
indexPrefix = 'hn_jobs-' # will have YYYY-MM-DD appended

batchSize = 200
batches = []
batchTypes = [
  { type: 'hiring', match: new RegExp 'ask hn: who is hiring?', 'i' }
  { type: 'freelance', match: new RegExp 'Seeking freelancer', 'i' }
  { type: 'looking', match: new RegExp 'Who wants to be hired?', 'i' }
]

# ES setup
client = new elasticsearch.Client
  host: esHost
  apiVersion: '1.4'
  # log: 'trace'

db = low 'data.json',
  autosave: false


# make ES is online
client.ping
  requestTimeout: 1000
.then (body) ->
  esDebug 'ping successful: %s', esHost
, (err) ->
  console.error err
  process.exit 1
.then ->
  createMapping client
.then ->
  runTasks()
  runBatches (err) ->
    if err
      console.log 'BATCH ERROR'
      return console.error err
    debug 'process complete'

runBatches = (cb) ->
  async.series batches, cb

runTasks = ->
  batchTypes.forEach (type) ->
    indextype type.match, type.type

queueBatch = (batch, type) ->
  bDebug 'batching %d items', batch.length / 2
  do ->
    batches.push (cb) ->
      esDebug 'creating %d "%s" records', batch.length / 2, type
      setTimeout ->
        client.bulk {
          body: batch
          requestTimeout: 60000
        }, cb
      , 3000

indextype = (match, type) ->
  items = db('comments').chain()
    .map (item) ->
      item.date_mst = moment(item.date).add(7, 'h').format('YYYY/MM/DD HH:mm:ss')
      item
    .filter (item) ->
      return if !item.title || !item.date
      item.title.match match
    .value()
  debug 'Type: %s - %d Matches', type, items.length

  batch = []
  items.forEach (item, i) ->
    batch.push { index:
      _index: indexPrefix + item.date.replace(/\-/g, '.')
      _type: type
      _id: item.id
    }
    batch.push item

    if batch.length >= (batchSize * 2)
      queueBatch batch.splice(0), type

  if batch.length > 0
    queueBatch batch.splice(0), type
