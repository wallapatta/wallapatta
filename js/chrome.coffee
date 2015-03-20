Mod.require 'Weya.Base',
 'Weya'
 'Editor'
 (Base, Weya, Editor) ->

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
     @$.elems.save = @i ".fa.fa-save", on: {click: @$.on.save}

    @elems.save.style.display = 'none'

   @listen 'openDirectory', (entry) ->
    return unless entry?

    chrome.storage.local.set
     directory: chrome.fileSystem.retainEntry entry

    @loadDirEntry entry

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

