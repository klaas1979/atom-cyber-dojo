module.exports =
class EditorElement
  constructor: (options) ->
    @element = document.createElement('div')

    # Add the message/label for the editor
    @message = document.createElement('div')
    @message.classList.add('message')
    @message.textContent = options?.label || ''
    @element.appendChild(@message)

    # Add the editor element
    @editor = document.createElement('atom-text-editor')
    @editor.setAttribute 'mini', true
    @editor.getModel().setText options?.text || ''
    @element.appendChild(@editor)

    # register callbacks
    atom.commands.add @editor, 'core:confirm', =>
    atom.commands.add @editor, 'core:cancel', =>

  # Puts focus into editor element.
  focus: ->
    @editor.focus()

  # Serializes this Editor State/text.
  serialize: ->
    @editor.getModel().getText()

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
