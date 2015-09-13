request = require 'request' # NPM package

module.exports =
class CyberDojoServer

  constructor: ->
    @serverState = {}
    @jar = request.jar()
    @client = null
    @dojoId = null
    @avatar = null

  setKata: (serverUrl, dojoId, avatar) ->
    @serverUrl = serverUrl
    @dojoId = dojoId
    @avatar = avatar
    console.log "setKata to server=#{serverUrl} DojoID=#{dojoId} avatar=#{avatar}"

  sync: (finishedCallback) ->
    url = "#{@serverUrl}/kata/show_json/#{@dojoId}?avatar=#{@avatar}"
    request.get({url: url, jar: @jar}, (error, response, body) =>
      if (!error && response.statusCode == 200)
        @serverState = JSON.parse body
        console.log @serverState
        finishedCallback true
      else
        errorMessage = "'#{url}' response.statusMessage=#{response.statusMessage} " +
          "response.statusCode=#{response.statusCode} Error=#{error}"
        console.log message + " , response object:\n"
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
      if data['deleted']
        console.log "'#{filename}' is deleted"
        formData["file_hashes_incoming[#{filename}]"] = 0
      else if data['changed']
        console.log "'#{filename}' is changed"
        formData["file_hashes_outgoing[#{filename}]"] = 1
        formData["file_hashes_incoming[#{filename}]"] = 0
      else
        console.log "'#{filename}' is unchanged"
        formData["file_hashes_outgoing[#{filename}]"] = 0
        formData["file_hashes_incoming[#{filename}]"] = 0
    console.log formData
    url = "#{@serverUrl}/kata/run_tests/#{@dojoId}?avatar=#{@avatar}"
    options = {
      url: url,
      jar: @jar,
      headers: {
        'X-CSRF-Token': @serverState['csrf_token'],
        # 'Accept': '*/*' returns standard answer
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

  testResult: ->
    @serverState['lights'][@serverState['lights'].length-1]['colour']

  output: ->
    @serverState['visible_files']['output']
