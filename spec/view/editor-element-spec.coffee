EditorElement = require '../../lib/view/editor-element'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "EditorElement", ->

  describe ".initialize", ->
    [editor, label, text] = []

    describe "with valid config data", ->
      beforeEach ->
        label = 'editor label'
        text = 'serializedState text'
        editor = new EditorElement {
          text: text
          label: label
          }

      it "sets correct label", ->
        result = editor.element.querySelector('.message')
        expect(result.textContent).toEqual label

      it "sets correct text in editor", ->
        result = editor.element.querySelector('.editor')
        expect(result.getModel().getText()).toEqual text
