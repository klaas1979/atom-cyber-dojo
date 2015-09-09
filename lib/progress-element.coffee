# Progress spinner for asynchronous tasks run on server.
class ProgressElement extends HTMLDivElement
  @TEXT_SNIPPETS = {
    sync: {
      progress: 'Syncing with server\u2026',
      success: 'Synchronized successful with server',
      failure: 'Synchronization error with server'
    },
    runTests: {
      progress: 'Running tests/specs\u2026',
      success: 'Tests/Specs success',
      failure: 'Tests/Specs could not be executed with server'
    }
  }

  constructor: ->
    @progress = null
    @success = null
    @failure = null

  setType: (type) ->
    @progress = ProgressElement.TEXT_SNIPPETS[type]['progress']
    @success = ProgressElement.TEXT_SNIPPETS[type]['success']
    @failure = ProgressElement.TEXT_SNIPPETS[type]['failure']

  setDestroy: (destroy) ->
    @destroy = destroy

  destroy: ->
    @destroy()

  createdCallback: ->
    @tabIndex = -1

  displayLoading: ->
    @innerHTML = """
      <span class="loading loading-spinner-small inline-block"></span>
      <span>
        #{@progress}
      </span>
    """

  displaySuccess: ->
    @innerHTML = """
      <span class="text-success">
        #{@success}
      </span>
    """

  displayFailure: ->
    @innerHTML = """
      <span class="text-error">
        #{@failure}
      </span>
    """

module.exports =
document.registerElement("cyber-dojo-progress",
  prototype: ProgressElement.prototype
  extends: "div"
)
