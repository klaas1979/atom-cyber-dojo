{$, TextEditorView, View}  = require 'atom-space-pen-views'
CyberDojoKata = require './cyber-dojo-kata.coffee'

module.exports =
# View to enter the URL to a cyberdojo kata.
class CyberDojoUrlView extends View

  @content: ->
    @div class: 'cyber-dojo', =>
      @subview 'miniEditor', new TextEditorView(mini: true)
      @div class: 'message', outlet: 'message'

  initialize: (url, successCallback) ->
    @validUrlEnteredCallback = successCallback
    @panel = atom.workspace.addModalPanel(item: this, visible: false)
    @miniEditor.setText url

    # no close on blur -> stay open till use cancels or confirms
    # @miniEditor.on 'blur', => @close()

    atom.commands.add @miniEditor.element, 'core:confirm', => @confirm()
    atom.commands.add @miniEditor.element, 'core:cancel', => @close()

  toggle: ->
    if @panel.isVisible() then @close() else @open()

  close: ->
    return unless @panel.isVisible()

    miniEditorFocused = @miniEditor.hasFocus()
    @panel.hide()
    @restoreFocus() if miniEditorFocused

  confirm: ->
    kata = CyberDojoKata.forUrl @miniEditor.getText()
    if kata
      @validUrlEnteredCallback kata
    else
      atom.notifications?.addError "Not a valid URL: '#{@miniEditor.getText()}'"
    @close()

  storeFocusedElement: ->
    @previouslyFocusedElement = $(':focus')

  restoreFocus: ->
    if @previouslyFocusedElement?.isOnDom()
      @previouslyFocusedElement.focus()
    else
      atom.views.getView(atom.workspace).focus()

  open: ->
    return if @panel.isVisible()

    if editor = atom.workspace.getActiveTextEditor()
      @storeFocusedElement()
      @panel.show()
      @message.text("Enter cyber-dojo kata URL")
      @miniEditor.focus()
