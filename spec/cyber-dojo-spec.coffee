CyberDojo = require '../lib/cyber-dojo'
temp = require 'temp'

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

    describe "and no cyber-dojo.workspace is set", ->

      it "opens atom.pickFolder and set picked folder as workspace config", ->
        tempDir = temp.mkdirSync('a-new-cyberdojo-workspace')
        spyOn(atom, 'pickFolder').andCallFake (callback) -> callback([tempDir])

        atom.commands.dispatch workspaceElement, 'cyber-dojo:url'

        waitsForPromise -> activationPromise
        runs ->
          expect(atom.config.get 'cyber-dojo.workspace').toEqual tempDir

    # describe "and cyber-dojo.workspace is set", ->
    #
    #   it "opens the modal panel to enter Kata URL", ->
    #     jasmine.attachToDOM(workspaceElement)
    #
    #     tempDir = temp.mkdirSync('a-new-cyberdojo-workspace')
    #     atom.config.set 'cyber-dojo.workspace', tempDir
    #
    #     atom.commands.dispatch workspaceElement, 'cyber-dojo:url'
    #     waitsForPromise -> activationPromise
    #
    #     runs ->
    #       cyberDojoElement = workspaceElement.querySelector('.cyber-dojo')
    #       expect(cyberDojoElement).toBeVisible()
    #
    #   runs ->
    #     # Now we can test for view visibility
    #     testsStuffElement = workspaceElement.querySelector('.tests-stuff')
    #     expect(testsStuffElement).toBeVisible()
    #     atom.commands.dispatch workspaceElement, 'tests-stuff:toggle'
    #     expect(testsStuffElement).not.toBeVisible()
