_ = require 'lodash'
moment = require 'moment'
debug = require('debug')('truncate')

truncateMonth = (db, month_str) ->
  month_str = moment(month_str).format 'MMMM YYYY'
  debug "Truncating records for #{month_str}"
  submissions = db('submissions').filter (sub) -> sub.title.match(month_str)

  _.each submissions, (sub) ->
    db('comments').remove submission_id: sub.id
    db('submissions').remove id: sub.id
    db('links').pull sub.url
  db.save()

module.exports = truncateMonth