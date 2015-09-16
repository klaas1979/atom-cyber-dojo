module.exports =
class ModalEditor
  constructor: (serializedState, callback) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('tests-stuff')

    # Create message element
    @editor = document.createElement('atom-text-editor')
    @editor.setAttribute 'mini', true
    @element.appendChild(@editor)

    @message = document.createElement('div')
    @message.classList.add('message')
    @message.textContent = 'Enter Cyber-Dojo kata URL'
    @element.appendChild(@message)

    # register callbacks
    atom.commands.add @editor, 'core:confirm', => callback(@editor.getModel().getText())
    atom.commands.add @editor, 'core:cancel', => callback(@editor.getModel().getText())

  # PUts focus into editor
  focus: ->
    @editor.focus()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
