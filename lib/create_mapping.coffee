esDebug = require('debug') 'elasticsearch'

templateName = 'hn_jobs'

props =
  "author":
    "type": "string", "index": "not_analyzed"
  "comment":
    "type": "string"
  "comment_raw":
    "type": "string", "index": "not_analyzed"
  "date":
    "type": "date", "format": "dateOptionalTime"
  "id":
    "type": "string"
  "links":
    "type": "string"
  "posted":
    "type": "string"
  "submission_id":
    "type": "string"
  "title":
    "type": "string"

body =
  "template": "hn_jobs-*",
  "mappings":
    "hiring":
      "properties": props
    "looking":
      "properties": props
    "freelance":
      "properties": props

module.exports = (client) ->
  client.indices.getTemplate
    name: templateName
  .then (res) ->
    esDebug 'template %s already exists', templateName
  .catch (err) ->
    if err.status isnt 404
      return console.error err

    esDebug 'create template %s', templateName
    client.indices.putTemplate
      name: templateName
      order: 0
      body: body
