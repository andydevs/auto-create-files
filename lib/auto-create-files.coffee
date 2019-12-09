# Auto Create Files
#
# Automatically creates project files
#
# Author:  Anshul Kharbanda
# Created: 10 - 20 - 2017
TemplateSelector = require './template-selector'
{CompositeDisposable} = require 'atom'

# Export class file
module.exports = AutoCreateFiles =
  # Configuration
  config:
    fullname:
      type: 'string'
      default: '[fullname]'

  # Member variables
  subscriptions: null
  templateSelector: null
  panel: null

  # Activates the package
  #
  # @param state the current state of the package
  activate: (state) ->
    # Register commands list
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'auto-create-files:gitignore': => @gitignore()
      'auto-create-files:license': => @license()

  # Returns empty serialization
  serialize: -> {}

  # Deactivates the package
  deactivate: ->
    @closeWindow()
    @subscriptions.dispose()

  # Show created template selector
  showTemplateSelector: ->
    console.log 'Show creator window.'
    @panel = atom.workspace.addModalPanel
      item: @templateSelector.selectorView.element
      visible: true
    @templateSelector.selectorView.focus()

  # Creates a new .gitignore file
  gitignore: ->
    # Create template selector
    @templateSelector = new TemplateSelector
      filename: '.gitignore'
      apiUrl: '/gitignore/templates'
      responseMapper: (item) -> item
      getSource: (data) -> data.source
      closePanel: => @closeWindow()

    # Show template selector
    @showTemplateSelector()

  # Creates a new LICENSE file
  license: ->
    # Create template selector
    @templateSelector = new TemplateSelector
      filename: 'LICENSE'
      apiUrl: '/licenses'
      responseMapper: (item) -> item.spdx_id
      getSource: (data) -> data.body
      closePanel: => @closeWindow()

    # Show template selector
    @showTemplateSelector()

  # Closes the select list window
  closeWindow: ->
    console.log 'Closing modal panel...'
    @panel.destroy()
    @templateSelector.destroy()
