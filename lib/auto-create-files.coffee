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
    # Member variables
    templateSelector: null
    panel: null
    subscriptions: null

    # Activates the package
    #
    # @param state the current state of the package
    activate: (state) ->
        # Register commands list
        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.commands.add 'atom-workspace',
            'auto-create-files:gitignore': => @gitignore()

    # Returns empty serialization
    serialize: -> {}

    # Deactivates the package
    deactivate: ->
        @closeWindow()
        @subscriptions.dispose()

    # Creates a new .gitignore file
    gitignore: ->
        # Create select list view
        @templateSelector = new TemplateSelector
            closePanel: => @closeWindow()
            filename: '.gitignore'
            listUrl: '/gitignore/templates'
            fileUrl: (type) -> ('/gitignore/templates'+type)

        # Create modal panel
        console.log 'Show creator window.'
        @panel = atom.workspace.addModalPanel
            item: @templateSelector.selectorView.element
            visible: true
        @templateSelector.selectorView.focus()

    # Closes the select list window
    closeWindow: ->
        console.log 'Closing modal panel...'
        @panel.destroy()
        @templateSelector.destroy()
