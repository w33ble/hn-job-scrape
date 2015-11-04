truncateMonth = require './truncate_month'

preProcess = (db) ->
  truncateMonth db

module.exports = preProcess