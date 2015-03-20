Mod.require 'Weya.Base',
 'Weya'
 'Editor'
 (Base, Weya, Editor) ->

  window.wallapattaDecodeURL = (url) ->
   if APP.resources[url]?
    return APP.resources[url]
   else
    return url

  class App extends Base
   @initialize ->
    @elems = {}
    @resources = {}
    window.requestAnimationFrame =>
     @render()

   @listen 'error', (e) ->
    console.error e

   render: ->
    @elems.toolbar = document.getElementById 'toolbar'
    Weya elem: @elems.toolbar, context: this, ->
     @$.elems.folder = @i ".fa.fa-folder-open", on: {click: @$.on.folder}
     @$.elems.open = @i ".fa.fa-file", on: {click: @$.on.file}
     @$.elems.save = @span ->
      @i ".fa.fa-save", on: {click: @$.on.save}
      @$.elems.saveName = @span ".file-name", ""

    @elems.save.style.display = 'none'

   @listen 'save', (e) ->
    return unless @file?

    @file.createWriter @on.writer, @on.error

   @listen 'writeEnd', (e) ->
    console.log 'write end', e
    if @contentWriting?
     @content = @contentWriting
     @contentWriting = null

   @listen 'writer', (writer) ->
    writer.onerror = @on.error
    writer.onwriteend = @on.writeEnd

    blob = new Blob [Editor.getText()], type: 'text/plain'
    @contentWriting = Editor.getText()

    writer.truncate blob.size
    @waitForIO writer, ->
     writer.seek 0
     writer.write blob

   waitForIO: (writer, callback) ->
    start = Date.now()
    reentrant = ->
     if writer.readyState is writer.WRITING and Date.now() - start < 4000
      setTimeout reentrant, 100

     if writer.readyState is writer.WRITING
       console.error "Write operation taking too long, aborting!
          (current writer readyState is #{writer.readyState})"
       writer.abort()
     else
      callback()

    setTimeout reentrant, 100

   @listen 'openDirectory', (entry) ->
    return unless entry?

    chrome.storage.local.set
     directory: chrome.fileSystem.retainEntry entry

    @loadDirEntry entry

   @listen 'file', (e) ->
    chrome.fileSystem.chooseEntry
     type: 'openFile'
     @on.openFile

   @listen 'watchChanges', ->
    if Editor.getText() isnt @content
     @elems.saveName.textContent = "*#{@file.name}"
    else
     @elems.saveName.textContent = "#{@file.name}"

   @listen 'openFile', (entry) ->
    return unless entry?

    chrome.storage.local.set
     file: chrome.fileSystem.retainEntry entry

    @elems.save.style.display = 'inline-block'
    @elems.saveName.textContent = entry.name
    setInterval @on.watchChanges, 500
    @file = entry
    self = this
    entry.file (file) =>
     reader = new FileReader()

     reader.onerror = @on.error
     reader.onload = (e) ->
      Editor.setText e.target.result
      self.content = e.target.result

     reader.readAsText file


   @listen 'folder', (e) ->
    chrome.fileSystem.chooseEntry type: 'openDirectory', @on.openDirectory

   addResource: (entry) ->
    entry.file (file) =>
     @resources[entry.fullPath] = window.URL.createObjectURL file
     console.log entry.fullPath

   loadDirEntry: (entry, callback) ->
    return unless entry.isDirectory
    console.log entry.fullPath
    reader = entry.createReader()
    self = this
    dirs = []

    readEntries = ->
     reader.readEntries onRead, self.on.error

    onRead = (results) ->
     if results.length is 0
      for e in dirs
       self.loadDirEntry e
      dirs = []
      return

     for e in results
      if e.isDirectory
       dirs.push e
      else
       self.addResource e
      readEntries()

    readEntries()

  APP = new App()

