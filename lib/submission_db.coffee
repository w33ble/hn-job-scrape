lvl = require 'level'

db = lvl './leveldb/submissions',
  valueEncoding: 'json'

module.exports = db