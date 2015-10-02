request = require 'request' # NPM package

module.exports =
class CyberDojoServer

  constructor: (serializedState) ->
    @serverState = serializedState?.serverState || {}
    @jar = serializedState?.jar || request.jar()
    @kata = serializedState?.kata || null

  serialize: ->
    {
      serverState: @serverState
      jar: @jar
      kata: @kata
    }

  url: ->
    kata?.url || ''

  isKataDefined: ->
    @kata?.valid()

  setKata: (kata) ->
    @kata = kata

  sync: (finishedCallback) ->
    request.get({url: @kata.show_json_url(), jar: @jar}, (error, response, body) =>
      if (!error && response.statusCode == 200)
        @serverState = JSON.parse body
        console.log @serverState
        finishedCallback true
      else
        errorMessage = "'#{@kata.show_json_url()}' response.statusMessage=#{response.statusMessage} " +
          "response.statusCode=#{response.statusCode}\nBody=#{response.body}\nError=#{error}"
        console.log errorMessage + " , response object:\n"
        console.log response
        finishedCallback false, errorMessage
    )

  files: ->
    console.log @serverState
    @serverState?.visible_files

  runTests: (localState, finishedCallback) ->
    formData = { authenticity_token: @serverState['csrf_token'] }
    for filename, data of localState
      formData["file_content[#{filename}]"] = data['content']
      if data.deleted
        console.log "'#{filename}' is deleted"
        formData["file_hashes_incoming[#{filename}]"] = 0
      else if data.changed
        console.log "'#{filename}' is changed"
        formData["file_hashes_outgoing[#{filename}]"] = 1
        formData["file_hashes_incoming[#{filename}]"] = 0
      else
        console.log "'#{filename}' is unchanged"
        formData["file_hashes_outgoing[#{filename}]"] = 0
        formData["file_hashes_incoming[#{filename}]"] = 0
    console.log formData
    options = {
      url: @kata.run_tests_url(),
      jar: @jar,
      headers: {
        'X-CSRF-Token': @serverState['csrf_token'],
        'Accept': 'application/json; charset=UTF-8'
      },
      form: formData
    }
    console.log options
    request.post(options, (error, response, body) =>
      if (!error && response.statusCode == 200)
        @serverState = JSON.parse body
        console.log @serverState
        finishedCallback(true)
      else
        console.log "'#{url}' response.statusCode=#{response.statusCode} Error=#{error}"
        finishedCallback(false)
    )

  lights: ->
    @serverState.lights

  testResult: ->
    lights = @lights()
    lights[lights.length-1].colour

  output: ->
    @serverState.visible_files.output
