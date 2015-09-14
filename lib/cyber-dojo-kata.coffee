module.exports =
# Value object containing kata data like URL, avatar and dojoId.
class CyberDojoKata

  constructor: (@url, @serverUrl, @dojoId, @avatar) ->

  @forUrl: (url) ->
    urlPattern = /// ^ # begin of line
      (http://.*)      # any server with protocol
      /kata/edit/      # match kata URL edit
      (\w+)            # match the Dojo ID
      \?avatar=        # avatar paramater
      (\w+)            # avatar name
      $ ///i           # end of line and ignore case
    matched = url.match(urlPattern)

    if matched then new CyberDojoKata url, matched[1], matched[2], matched[3] else null

  valid: ->
    @url != null && @serverUrl != null && @dojoId != null && @avatar != null

  show_json_url: ->
    "#{@serverUrl}/kata/show_json/#{@dojoId}?avatar=#{@avatar}"

  run_tests_url: ->
    "#{@serverUrl}/kata/run_tests/#{@dojoId}?avatar=#{@avatar}"
