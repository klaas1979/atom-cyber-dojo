CyberDojo = require '../lib/cyber-dojo'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "CyberDojo", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('cyber-dojo')

  describe "when the cyber-dojo:url event is triggered", ->
    it "hides and shows the url view", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.cyber-dojo')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'cyber-dojo:url'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.cyber-dojo')).toExist()

        cyberDojoElement = workspaceElement.querySelector('.cyber-dojo')
        expect(cyberDojoElement).toExist()

        cyberDojoPanel = atom.workspace.panelForItem(cyberDojoElement)
        expect(cyberDojoPanel.isVisible()).toBe true
        atom.commands.dispatch workspaceElement, 'cyber-dojo:url'
        expect(cyberDojoPanel.isVisible()).toBe false

    it "hides and shows the view", ->
      # This test shows you an integration test testing at the view level.

      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.cyber-dojo')).not.toExist()

      # This is an activation event, triggering it causes the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'cyber-dojo:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        # Now we can test for view visibility
        cyberDojoElement = workspaceElement.querySelector('.cyber-dojo')
        expect(cyberDojoElement).toBeVisible()
        atom.commands.dispatch workspaceElement, 'cyber-dojo:toggle'
        expect(cyberDojoElement).not.toBeVisible()
