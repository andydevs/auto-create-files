# Auto Create Files
#
# Automatically creates project files
#
# Author:  Anshul Kharbanda
# Created: 10 - 20 - 2017
SelectListView = require 'atom-select-list'
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

# Pulls entire text from an https get
#
# @param url the url to get from
#
# @return entire text from https get
httpsPullText = (url, callback) ->
    https.get githubApiGet(url), (response) ->
        data = ''
        response.on 'data', (chunk) ->
            data += chunk
        response.on 'end', ->
            callback(data)

# Selection of Templates
class TemplateSelector
    # Members
    closePanel: null
    filename: null
    listUrl: null
    fileUrl: null
    filepath: null
    selectorView: null

    # Creates a new TemplateSelectorView
    constructor: (props) ->
        # Get props
        @closePanel = props.closePanel
        @filename = props.filename
        @listUrl = props.listUrl
        @fileUrl = props.fileUrl
        @filepath = path.join atom.project.getPaths()[0], @filename

        # Create SelectListView
        @selectorView = new SelectListView
            items: []
            elementForItem: (item) => @itemView(item)
            didCancelSelection: => @closePanel()
            didConfirmSelection: (type) => @create(type)
        @selectorView.element.classList.add 'auto-create-files'

        # Get gitignore templates
        httpsPullText @listUrl, (data) =>
            items = JSON.parse(data)
            console.log 'Available '+@filename+' templates:'
            console.log items
            @selectorView.update
                items: items

    # Destroy TemplateSelector
    destroy: ->
        @selectorView.destroy()

    # View for item
    itemView: (item) ->
        elem = document.createElement 'li'
        elem.textContent = item
        elem

    # Creates a new file of the given type
    create: (type) ->
        # Print message
        console.log ('Creating '+type+'...')

        # Get file and write
        httpsPullText @fileUrl(type), (data) =>
            fs.writeFile @filepath, JSON.parse(data).source, (err) =>
                throw err if err?
                console.log (type+' '+@filename+' created!')
                atom.notifications.addSuccess (type+' '+@filename+' created!')

        # Close panel
        @closePanel()

# Export class
module.exports = TemplateSelector
