esDebug = require('debug') 'elasticsearch'

templateName = 'hn_jobs'

props =
  author:
    type: "string"
    index: "not_analyzed"
  comment:
    type: "string"
    # index: "analyzed"
    analyzer: "my_analyzer"
  comment_raw:
    type: "string"
    index: "not_analyzed"
  date:
    type: "date"
    format: "date"
  date_mst:
    type: "date"
    format: "yyyy/MM/dd HH:mm:ss||yyyy/MM/dd"
  id:
    type: "string"
  links:
    type: "string"
  posted:
    type: "string"
  submission_id:
    type: "string"
  title:
    type: "string"

body =
  template: "hn_jobs-*",
  mappings:
    _default_:
      properties: props
    # hiring:
    #   properties: props
    # looking:
    #   properties: props
    # freelance:
    #   properties: props
  settings:
    analysis:
      analyzer:
        my_analyzer:
          type: 'custom'
          tokenizer: 'uax_url_email'
          filter: [
            'standard'
            'lowercase'
            'unique'
            'stop'
            'my_words'
            'my_snow'
          ]
          char_filter: [
            'html_strip'
          ]
      filter:
        my_snow:
          type: 'snowball'
          language: 'English'
        my_words:
          type: 'stop'
          stopwords: [
            'i'
            'i\'m'
            't'
          ]


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
