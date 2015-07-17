_ = require 'lodash'
moment = require 'moment'

preProcess = (db) ->
  thisMonth = moment().format 'MMMM YYYY'
  submissions = db('submissions').filter (sub) -> sub.title.match(thisMonth)

  _.each submissions, (sub) ->
    db('comments').remove submission_id: sub.id
    db('submissions').remove id: sub.id
    db('links').pull sub.url
  db.save()

module.exports = preProcess