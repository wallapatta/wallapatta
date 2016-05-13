Mod.require 'Weya.Base',
 'Weya'
 'Editor'
 (Base, Weya, Editor) ->
  ELECTRON = require 'electron'
  IPC = ELECTRON.ipcRenderer
  FS = require 'fs'
  PATH = require 'path'

  TEMPORARY_FILE = 'temporary.swp.ds'
  OPTIONS_FILE = 'options.json'
  TEMPORARY_SAVE_INTERVAL = 30 * 1000
  CHANGED_WATCH_INTERVAL = 500

  PROTOCOLS = [
   'https://'
   'http://'
   'file://'
  ]

  window.wallapattaDecodeURL = (url) ->
   for protocol in PROTOCOLS
    if (url.substr 0, protocol.length) is protocol
     return url

   return url if not APP.folder?
   url = "/#{url}" if url[0] isnt '/'
   return "#{APP.folder.url}#{url}"

  class App extends Base
   @initialize ->
    @elems = {}
    @resources = {}
    @_editorChanged = false
    @content = ''
    @options =
     file: ''
     folder: ''
    @editor = new Editor
     openUrl: @on.openUrl
     onChanged: @on.editorChanged

   load: (callback) ->
    IPC.on 'userDataPath', (e, path) =>
     @_userDataPath = path
     #TODO load options, temporary
     callback()
    IPC.send 'getUserDataPath'

   @listen 'error', (e) ->
    console.error e

   @listen 'editorChanged', ->
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
          style: {display: 'none'}
          on: {click: @$.on.save}
          ->
           @span ".icon.icon-download.icon-text", null
           @$.elems.saveName = @span ""
         @button ".btn.btn-default",
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

    @editor.render @elems.editor, @elems.editorToolbar, =>
     @_watchInterval = setInterval @on.watchChanges, CHANGED_WATCH_INTERVAL
     @_saveTemInterval = setInterval @on.saveTemporary, TEMPORARY_SAVE_INTERVAL
     callback()

   @listen 'folder', -> IPC.send 'openFolder'
   @listen 'folderOpened', (e, folders) ->
    console.log folders
    return if not folders?
    return if folders.length <= 0
    folder = folders[0]
    url = folder.split PATH.sep
    url.shift() while url.length > 0 and url[0] is ''
    return if not url.length > 1
    url = ['file://'].concat folder.split PATH.sep
    url = url.slice 0, url.length - 1
    @folder =
     path: folder
     url: url.join '/'
    @options.folder = @folder.path
    @saveOptions()
    @editor.setText @removeTrailingSpace @editor.getText()

   @listen 'file', -> IPC.send 'openFile'
   @listen 'fileOpened', (e, files) ->
    return if not files?
    return if files.length <= 0
    file = files[0]
    @file =
     name: PATH.basename file, '.ds'
     path: file
    @content = "#{FS.readFileSync file}"
    @editor.setText @content
    @_editorChanged = true
    @on.saveTemporary()
    @options.file = @file.path
    @saveOptions()
    @elems.save.style.display = 'inline-block'
    @elems.saveName.textContent = "#{@file.name}"

   @listen 'save', ->
    @content = @removeTrailingSpace @editor.getText()
    @editor.setText @content
    FS.writeFile @file.path, @content, (err) ->
     if err?
      console.error err
     else
      console.log 'file saved'

   @listen 'saveAs', -> IPC.send 'saveFile'
   @listen 'saveFile', (e, file) ->
    return if not file?
    @file =
     name: PATH.basename file, '.ds'
     path: file
    @content = @removeTrailingSpace @editor.getText()
    @editor.setText @content
    @_editorChanged = true
    @on.saveTemporary()
    @options.file = @file.path
    @saveOptions()
    @elems.save.style.display = 'inline-block'
    @elems.saveName.textContent = "#{@file.name}"

   @listen 'print', ->
    @editor.on.print()

   removeTrailingSpace: (text) ->
    lines = text.split '\n'
    for line, i in lines
     lines[i] = line.trimRight()

    lines.join '\n'

   saveOptions: ->
    FS.writeFile (PATH.join @_userDataPath, OPTIONS_FILE),
     (JSON.stringify @options)
     (err) ->
      if err?
       console.error err
      else
       console.log 'options file saved'

   @listen 'saveTemporary', ->
    return if not @file?
    return if not @_editorChanged
    FS.writeFile (PATH.join @_userDataPath, TEMPORARY_FILE),
     @editor.getText()
     (err) ->
      if err?
       console.error err
      else
       console.log 'temporary file saved'
    @_editorChanged = false
    @elems.saveName.style.color = '#333'

   @listen 'watchChanges', ->
    return if not @file?
    if @editor.getText() isnt @content
     @elems.saveName.textContent = "#{@file.name} *"
     if @_editorChanged
      @elems.saveName.style.color = '#c00'
    else
     @elems.saveName.textContent = "#{@file.name}"



  APP = new App()
  IPC.on 'fileOpened', APP.on.fileOpened
  IPC.on 'folderOpened', APP.on.folderOpened
  IPC.on 'saveFile', APP.on.saveFile
  APP.load ->
   APP.render ->

