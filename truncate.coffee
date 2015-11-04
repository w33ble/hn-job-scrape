low = require 'lowdb'
truncate_month = require './lib/truncate_month'
db = low 'data.json',
  autosave: false

opts = process.argv.slice(2)

if opts.length isnt 2
  throw new Error('Expected format: YYYY MM')

year = opts[0]
month = opts[1]

truncate_month db, "#{year}-#{month}-01"