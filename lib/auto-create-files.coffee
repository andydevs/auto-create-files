# Auto Create Files
#
# Automatically creates project files
#
# Author:  Anshul Kharbanda
# Created: 10 - 20 - 2017
SelectListView = require 'atom-select-list'
{CompositeDisposable} = require 'atom'
https = require 'https'
fs = require 'fs'
path = require 'path'

# Configuration for gitignore
GITHUB_API_CONFIG =
    hostname: 'api.github.com'
    headers:
        'Accept': 'application/vnd.github.v3+json'
        'User-Agent': 'Atom-Gitignores-Package'

# Returns a github api config for the given path
#
# @param path the path of the api
#
# @return github api config
githubApiGet = (path) ->
    config = GITHUB_API_CONFIG
    config.path = path
    config

# Export class file
module.exports = AutoCreateFiles =
    # Member variables
    selectorView: null
    filepath: null
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

        # Create Select List View
        @selectorView = new SelectListView
            items: []
            elementForItem: (item) => @itemView(item)
            didCancelSelection: => @closeWindow()
            didConfirmSelection: (type) => @create(type)
        @selectorView.element.classList.add 'auto-create-files'

        # Add view to modal panel
        @panel = atom.workspace.addModalPanel
            item: @selectorView.element
            visible: false

        # Get gitignore templates
        https.get githubApiGet('/gitignore/templates'), (response) =>
            data = ''
            response.on 'data', (chunk) =>
                data += chunk
            response.on 'end', =>
                items = JSON.parse(data)
                console.log 'Available gitignore templates:'
                console.log items
                @selectorView.update
                    items: items

        # Get filepath
        @filepath = path.join atom.project.getPaths()[0], '.gitignore'

    # Returns empty serialization
    serialize: -> {}

    # Deactivates the package
    deactivate: ->
        @panel.destroy()
        @selectorView.destroy()
        @subscriptions.dispose()

    # Creates a new .gitignore file
    gitignore: ->
        console.log 'Show gitignore creator window.'
        @panel.show()
        @selectorView.focus()

    # View for item
    itemView: (item) ->
        elem = document.createElement 'li'
        elem.textContent = item
        elem

    # Closes the select list window
    closeWindow: ->
        console.log 'Closing modal panel...'
        @panel.hide()

    # Creates a new file of the given type
    create: (type) ->
        # Print message
        console.log ('Creating '+type+'...')

        # Get file and write
        https.get githubApiGet('/gitignore/templates/'+type), (response) =>
            data = ''
            response.on 'data', (chunk) =>
                data += chunk
            response.on 'end', =>
                fs.writeFile @filepath, JSON.parse(data).source, (err) =>
                    throw err if err?
                    console.log (type+' .gitignore created!')
                    atom.notifications.addSuccess (type+' .gitignore created!')

        # Close window
        @closeWindow()
