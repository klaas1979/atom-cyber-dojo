{CompositeDisposable} = require 'atom'

CyberDojoUrlView = require './cyber-dojo-url-view.coffee'
ProgressElement = require './progress-element.coffee'
CyberDojoClient = require './cyber-dojo-client.coffee'
CyberDojoSettings = require './cyber-dojo-settings.coffee'
CyberDojoServer = require './cyber-dojo-server.coffee'

module.exports =
  config:
    workspace:
      type: 'string'
      default: 'Cyber-Dojo workspace must be defined'

  cyberDojoSettings: null
  cyberDojoServer: null
  cyberDojoClient: null
  cyberDojoUrlView: null
  subscriptions: null

# TODO
# 1. ask to save text editors prior testing -> autosave feature instead
# 2. open output file and give focus if not open after test and amber/red?
# 3. provide possibility to revert to previous lights
# 4. resync with server -> other than 'toggle'
# 5. waiting for JonJagger to accept pull request with REST API for this package
# 6. create some tests for the plugin
# run tests only starts with valid kata check it!

  activate: (serializedState) ->
    @subscriptions = new CompositeDisposable()
    @cyberDojoSettings = new CyberDojoSettings()
    @cyberDojoServer = new CyberDojoServer serializedState.serverState
    @cyberDojoClient = new CyberDojoClient(serializedState.clientState,
      @cyberDojoSettings)
    @cyberDojoUrlView = new CyberDojoUrlView @cyberDojoServer.url(), (kata) =>
        @configureKata(kata)
    # register commands
    # activates cyber-dojo with a kata url
    @subscriptions.add atom.commands.add 'atom-workspace', 'cyber-dojo:url', =>
      @enterUrl()

    # run tests on server and display the results
    @subscriptions.add atom.commands.add 'atom-workspace', 'cyber-dojo:run-tests', =>
      @runTests()

  enterUrl: ->
    @setupCyberDojoWorkspace()
    @cyberDojoUrlView.toggle()

  # Ensures that user has set a cyber-dojo:workspace in his settings.
  # If no workspace is set the user is ask to select one!
  # the Workspace is the directory where all files from a dojo are saved to
  # all other files that do not belong to a dojo will be deleted!
  setupCyberDojoWorkspace: ->
    settings = @cyberDojoSettings
    unless  @cyberDojoSettings.workspaceExists()
      console.log 'No workspace set, ask User for workspace directory'
      atom.pickFolder (paths) ->
        if paths[0]?
          settings.setWorkspacePath(paths[0])
          atom.notifications.addInfo "Selected Cyber-Dojo workspace '#{paths[0]}'"
          atom.project.addPath(settings.getWorkspacePath())
          console.log "Set workspace to '#{paths[0]}' and added it as project path"
          atom.notifications.addSuccess "Setting cyber-dojo workspace to '#{paths[0]}'"
    else
      console.log "adding project path: " + settings.getWorkspacePath()
      atom.project.addPath(settings.getWorkspacePath())

    atom.notifications.addInfo "BEWARE: All files within Cyber-Dojo Workspace " +
      "'#{settings.getWorkspacePath()}'\nwill be deleted, if you start a new Kata!"

  deactivate: ->
    @cyberDojoUrlView.destroy()
    @subscriptions.dispose()

  serialize: ->
    {
      clientState: @cyberDojoClient.getInitialState(),
      serverState: @cyberDojoServer.serialize()
    }

  # Callback method to initialize the current kata.
  # Sets the server URL the dojoId and avatar to use.
  configureKata: (kata) ->
    client = @cyberDojoClient
    server = @cyberDojoServer

    server.setKata kata
    view = @displayProgress('sync')
    server.sync (success, message) =>
      if success
        client.saveState(server.files())
        atom.notifications.addInfo "Successfully synced kata"
      else
        atom.notifications.addError message
      view.destroy()

  # Executes the tests on cyber-dojo-server and displays the result.
  runTests: ->
    if @cyberDojoServer.isKataDefined()
      view = @displayProgress('runTests')
      @cyberDojoClient.getState (localState) =>
        @cyberDojoServer.runTests localState, (success) =>
          if success
            @cyberDojoClient.saveState(@cyberDojoServer.files())
            output = @cyberDojoServer.output()
            switch @cyberDojoServer.testResult()
              when 'green'
                atom.notifications.addSuccess(output)
              when 'amber'
                atom.notifications.addWarning(output)
              when 'red'
                atom.notifications.addError(output)
            view.destroy()
          else
            view.displayFailure()
    else
      atom.notifications.addInfo "No Cyber-Dojo URL set, set one prior running the tests"

  # Creates a Progess View for asynchronous tasks running on the
  # cyber dojo server.
  displayProgress: (type) ->
    view = new ProgressElement()
    view.setType(type)
    panel = atom.workspace.addModalPanel(item: view)
    view.setDestroy ->
      panel.destroy()

    view.displayLoading()
    view.focus()

    atom.commands.add view, 'core:cancel', ->
      view.destroy()

    view
