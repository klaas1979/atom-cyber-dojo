{Directory} = require 'atom'

module.exports =
# The packages Settings.
class CyberDojoSettings

  # Exists the configured workspace.
  workspaceExists: ->
    @getWorkspace().existsSync()

  # Atom Directory for configured workspace.
  getWorkspace: ->
    new Directory @getWorkspacePath()

  # Path to corrent workspace setting as string.
  getWorkspacePath: ->
    atom.config.get 'cyber-dojo.workspace'

  # Updates workspace setting to given path.
  setWorkspacePath: (path) ->
    atom.config.set 'cyber-dojo.workspace', path
