# Auto Create Files
#
# Automatically creates project files
#
# Author:  Anshul Kharbanda
# Created: 10 - 20 - 2017

# Describe Gitignore
describe 'Gitignore', ->
    # Variables
    activatedPromise = null
    workspaceView = null

    # Do before each
    beforeEach ->
        activatedPromise = atom.packages.activatePackage 'auto-create-files'
        workspaceView = atom.views.getView atom.workspace
        jasmine.attachToDOM workspaceView

    # Describe create command
    describe 'auto-create-files:gitignore', ->
        it 'Shows the selector panel', ->
            # Dispatch create command
            atom.commands.dispatch workspaceView, 'auto-create-files:gitignore'
            waitsForPromise -> activatedPromise

            # Run tests
            panels = atom.workspace.getModalPanels()
            expect(panels.length).toBeGreaterThan 0
            selectorView = panels[0].getItem()
            expect(selectorView.classList.contains 'select-list').toBeTruthy()
            expect(selectorView.classList.contains 'auto-create-files').toBeTruthy()

    # When selector view is open
    describe 'When selector view is open', ->
        # Describe cancel command
        describe 'core:cancel', ->
            it 'Closes the selecor panel', (done) ->
                # Dispatch create command
                atom.commands.dispatch workspaceView, 'auto-create-files:gitignore'
                waitsForPromise -> activatedPromise

                # Get selector view
                panels = atom.workspace.getModalPanels()
                selectorView = panels[0].getItem()

                # Dispath cancel command
                atom.commands.dispatch selectorView, 'core:cancel'
                atom.commands.onDidDispatch ->
                    panels = atom.workspace.getModalPanels()
                    expect(panels.length).toEqual 0
                    done()

        # Describe confirm command
        describe 'core:confirm', ->
            it 'Closes the selector panel', (done) ->
                # Dispatch create command
                atom.commands.dispatch workspaceView, 'auto-create-files:gitignore'
                waitsForPromise -> activatedPromise

                # Get selector view
                panels = atom.workspace.getModalPanels()
                selectorView = panels[0].getItem()

                # Dispath cancel command
                atom.commands.dispatch selectorView, 'core:cancel'
                atom.commands.onDidDispatch ->
                    # Check if selector view is gone
                    panels = atom.workspace.getModalPanels()
                    expect(panels.length).toEqual 0
                    done()

            it 'Closes the selector panel', (done) ->
                # Dispatch create command
                atom.commands.dispatch workspaceView, 'auto-create-files:gitignore'
                waitsForPromise -> activatedPromise

                # Get selector view
                panels = atom.workspace.getModalPanels()
                selectorView = panels[0].getItem()

                # Dispath cancel command
                atom.commands.dispatch selectorView, 'core:cancel'
                atom.commands.onDidDispatch ->
                    # Check if file has been written
                    filepath = path.join atom.project.path, '.gitignore'
                    expect(fs.existsSync filepath).toBeTruthy()
                    done()
