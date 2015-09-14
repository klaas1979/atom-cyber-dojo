{$, TextEditorView, View}  = require 'atom-space-pen-views'
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
    @miniEditor.setText(url || '')

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
    urlPattern = /// ^ # begin of line
      (http://.*)      # any server with protocol
      /kata/edit/      # match kata URL edit
      (\w+)            # match the Dojo ID
      \?avatar=        # avatar paramater
      (\w+)            # avatar name
      $ ///i           # end of line and ignore case
    url = @miniEditor.getText()
    matched = url.match(urlPattern)
    if matched
      @validUrlEnteredCallback url, matched[1], matched[2], matched[3]
    else
      atom.notifications?.addError "'#{url}' is not a valid cyber-dojo URL, pattern: #{urlPattern}"
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
