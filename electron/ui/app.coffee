Mod.require 'Weya.Base',
 'Weya'
 'Editor'
 (Base, Weya, Editor) ->
  ELECTRON = require 'electron'
  IPC = ELECTRON.ipcRenderer
  FS = require 'fs'

  PROTOCOLS = [
   'https://'
   'http://'
   'file://'
  ]

  window.wallapattaDecodeURL = (url) ->
   for protocol in PROTOCOLS
    if (url.substr 0, protocol.length) is protocol
     return url

   url = "/#{url}" if url[0] isnt '/'
   return "#{APP.resourcesPath}#{url}"

  class App extends Base
   @initialize ->
    @elems = {}
    @resources = {}
    @_changed = false
    @_editorChanged = false
    @content = ''
    @editor = new Editor
     openUrl: @on.openUrl
     onChanged: @on.changed

   @listen 'addResources', (data) ->
    console.log 'resources', data.length
    @resources = {}
    for d in data
     @resources[d.path] = d.dataURL
    @send 'resourcesAdded', {}
    text = @removeTrailingSpace @editor.getText()
    @editor.setText text

   @listen 'setText', (data) ->
    console.log (new Date), 'setText', data.saved
    if data.saved
     @content = data.content
    @editor.setText data.content
    @_changed = false
    if not @_watchInterval?
     @_watchInterval = setInterval @on.watchChanges, 500

   @listen 'error', (e) ->
    console.error e

   @listen 'change', ->
    @_editorChanged = true

   @listen 'openUrl', (url) ->
    @send 'openUrl', url: url


   render: (callback) ->
    @elems.container = document.body
    Weya elem: @elems.container, context: this, ->
     @div ".window", ->
      @header ".toolbar.toolbar-header", ->
       @div ".toolbar-actions", ->
        @div ".btn-group", ->
         @button ".btn.btn-default",
          title: "Select images folder"
          on: {click: @$.on.folder}
          ->
           @span ".icon.icon-folder", null
         @button ".btn.btn-default",
          title: "Open file"
          on: {click: @$.on.file}
          ->
           @span ".icon.icon-upload", null
         @$.elems.save = @button ".btn.btn-default",
          title: "Save file"
          on: {click: @$.on.save}
          ->
           @span ".icon.icon-download", null
         @$.elems.save = @button ".btn.btn-default",
          title: "Save file"
          on: {click: @$.on.saveAs}
          "SaveAs"
         @button ".btn.btn-default",
          title: "Print"
          on: {click: @$.on.print}
          ->
           @span ".icon.icon-print", null

        @$.elems.editorToolbar = @span ""

        @button ".btn.btn-default.pull-right",
         title: "Help"
         on: {click: @$.on.help}
         ->
          @span ".icon.icon-help", null

      @div ".window-content", ->
       @$.elems.editor = @div ".editor", ''

    #window.addEventListener 'resize', @on.resize

    @editor.render @elems.editor, @elems.editorToolbar, ->
     callback()

   @listen 'folder', ->
   @listen 'file', -> IPC.send 'openFile'
   @listen 'fileOpened', (e, files) ->
    return if not files?
    return if files.length <= 0
    file = files[0]
    console.log "#{FS.readFileSync file}"

   @listen 'save', ->
   @listen 'saveAs', ->
   @listen 'print', ->
    @editor.on.print()

   removeTrailingSpace: (text) ->
    lines = text.split '\n'
    for line, i in lines
     lines[i] = line.trimRight()

    lines.join '\n'

   @listen 'save', ->
    text = @removeTrailingSpace @editor.getText()
    @editor.setText text
    @content = text
    @send 'saveFileContent', content: text

   @listen 'watchChanges', ->
    if @_editorChanged
     @send 'change', content: @editor.getText()
     @_editorChanged = false
    if @editor.getText() isnt @content
     if not @_changed
      @send 'fileChanged', changed: true
      @_changed = true
    else
     if @_changed
      @send 'fileChanged', changed: false
      @_changed = false



  APP = new App()
  IPC.on 'fileOpened', APP.on.fileOpened
  APP.render ->

