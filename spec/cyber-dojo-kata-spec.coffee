CyberDojoKata = require '../lib/cyber-dojo-kata'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "CyberDojoKata", ->

  describe "forUrl", ->
    [url, serverUrl, dojoId, avatar] = []

    describe "with valid URL", ->
      beforeEach ->
        serverUrl = 'http://192.168.188.10:8000'
        dojoId = '8FB98C541B'
        avatar = 'snake'
        url = "#{serverUrl}/kata/edit/#{dojoId}?avatar=#{avatar}"

      it "contains correct URL", ->
        result = CyberDojoKata.forUrl url
        expect(result.url).toEqual url

      it "contains correct URL serverUrl", ->
        result = CyberDojoKata.forUrl url
        expect(result.serverUrl).toEqual serverUrl

      it "contains correct URL dojoId", ->
        result = CyberDojoKata.forUrl url
        expect(result.dojoId).toEqual dojoId

      it "contains correct URL avatar", ->
        result = CyberDojoKata.forUrl url
        expect(result.avatar).toEqual avatar

    describe "with invalid URL", ->
      it "return null for missing protocol", ->
        result = CyberDojoKata.forUrl '/kata/edit/8FB98C541B?avatar=snake'
        expect(result).toBe null

      it "return null for missing avatar", ->
        result = CyberDojoKata.forUrl 'http://192.168.188.10:8000/kata/edit/8FB98C541B?avatar='
        expect(result).toBe null

      it "return null for missing dojoId", ->
        result = CyberDojoKata.forUrl 'http://192.168.188.10:8000/kata/edit/?avatar=snake'
        expect(result).toBe null

      it "return null for wrong path", ->
        result = CyberDojoKata.forUrl 'http://192.168.188.10:8000/k/e/8FB98C541B?avatar=snake'
        expect(result).toBe null

  describe "show_json_url", ->
    [kata, url, serverUrl, dojoId, avatar] = []

    beforeEach ->
      serverUrl = 'http://192.168.188.10:8000'
      dojoId = '8FB98C541B'
      avatar = 'snake'
      url = "#{serverUrl}/kata/edit/#{dojoId}?avatar=#{avatar}"
      kata = new CyberDojoKata(url, serverUrl, dojoId, avatar)

    it "creates correct URL", ->
      result = kata.show_json_url()
      expect(result).toEqual "#{serverUrl}/kata/show_json/#{dojoId}?avatar=#{avatar}"

  describe "run_tests_url", ->
  [kata, url, serverUrl, dojoId, avatar] = []

  beforeEach ->
    serverUrl = 'http://192.168.188.10:8000'
    dojoId = '8FB98C541B'
    avatar = 'snake'
    url = "#{serverUrl}/kata/edit/#{dojoId}?avatar=#{avatar}"
    kata = new CyberDojoKata(url, serverUrl, dojoId, avatar)

  it "creates correct URL", ->
    result = kata.run_tests_url()
    expect(result).toEqual "#{serverUrl}/kata/run_tests/#{dojoId}?avatar=#{avatar}"
