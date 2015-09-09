{Directory} = require 'atom'
shell = require 'shell'

module.exports =
# Holds the local Cyber-Dojo state: Stores the initial state as received from server.
# Provides a localState containing all files with their content and if they
# did change from initial server state.
class CyberDojoClient

  constructor: (@settings) ->
    # map with key=filename and value=file content
    @initialServerState = {}

  # Stores the initial server file state and updates the workspace
  # files on disk.
  saveState: (files) ->
    for name, content of files
      @initialServerState[name] = content
    @removeDeletedFiles()
    @writeFiles()

  # Internal helper method to remove all files from workspace that
  # are not contained in inital server state.
  removeDeletedFiles: ->
    for file in @getWorkspaceFiles()
      filename = file.getBaseName()
      unless @initialServerState[filename]
        console.log "Moving '#{filename}' to trash"
        shell.moveItemToTrash(file.getPath())

  # Writes file state from server to workspace.
  writeFiles: ->
    workspace = @settings.getWorkspace()
    console.log "Saving kata files to '#{@settings.getWorkspacePath()}'"
    for name, content of @initialServerState
      file = workspace.getFile name
      file.write content
      console.log "Writing file '#{name}'"

  # Returns the current state for files as hash:
  # [filesname]: {content: [filecontent], changed: [true/false]}
  # changed flag is calculated based on initialServerState filecontent and
  # current file content.
  getState: (callback) ->
    result = {}
    baseFiles = @initialServerState
    for filename of baseFiles
      result[filename] = { deleted: true }

    workspaceFiles = @getWorkspaceFiles()
    fileReadPromises = workspaceFiles.map (file) ->
      file.read().then (content) ->
        { filename: file.getBaseName(), content:content }
    Promise.all(fileReadPromises).then (fileContents) ->
      for fileContent in fileContents
        result[fileContent['filename']] = {
          content: fileContent['content'],
          changed: fileContent['content'] != baseFiles[fileContent['filename']]
        }
      callback(result)

  # Returns all files (and no directories) from selected cyber-dojo workspace.
  getWorkspaceFiles: ->
    workspace = @settings.getWorkspace()
    entries = workspace.getEntriesSync()
    entries.filter (e) -> e.isFile()
