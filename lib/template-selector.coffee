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
        'Accept': 'application/vnd.github.drax-preview+json'
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

# Parses placeholders in text if text is MIT license
#
# @param text text to parse
#
# @return parsed text
parseMITLicense = (text) ->
    return text.replace /\[(\w+)\]/, (match, word) ->
        switch word
            when 'year' then return (new Date()).getFullYear()
            when 'fullname' then return atom.config.get('auto-create-files.fullname')
            else return match

# Selection of Templates
class TemplateSelector
    # Members
    closePanel: null
    filename: null
    apiUrl: null
    filepath: null
    responseMapper: null
    getSource: null
    selectorView: null

    # Creates a new TemplateSelectorView
    constructor: (props) ->
        # Get props
        @closePanel = props.closePanel
        @filename = props.filename
        @apiUrl = props.apiUrl
        @filepath = path.join atom.project.getPaths()[0], @filename
        @responseMapper = props.responseMapper
        @getSource = props.getSource

        # Create SelectListView
        @selectorView = new SelectListView
            items: []
            elementForItem: (item) => @itemView(item)
            didCancelSelection: => @closePanel()
            didConfirmSelection: (type) => @create(type)
        @selectorView.element.classList.add 'auto-create-files'

        # Get gitignore templates
        httpsPullText @apiUrl, (data) =>
            console.log(data)
            items = JSON.parse(data).map @responseMapper
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
        httpsPullText (@apiUrl+'/'+type), (data) =>
            source = @getSource(JSON.parse data)
            if type === 'MIT'
                source = parseMITLicense source

            fs.writeFile @filepath, source, (err) =>
                throw err if err?
                console.log (type+' '+@filename+' created!')
                atom.notifications.addSuccess (type+' '+@filename+' created!')

        # Close panel
        @closePanel()

# Export class
module.exports = TemplateSelector
