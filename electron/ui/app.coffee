Mod.require 'Weya.Base',
 'Weya'
 'Editor'
 (Base, Weya, Editor) ->

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
    @editor.setResources (path for path of @resources)

   send: (method, data) ->
    data.method = method
    PARENT.postMessage data, '*'

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
    @editor.render ->
     setTimeout ->
      toolbar = document.getElementById 'toolbar'
      toolbar.style.display = 'none'
     , 300

     callback()

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
  APP.render ->
   MESSAGE_HANDLER = (e) ->
    APP.on[e.data.method] e.data, e

   window.addEventListener 'message', MESSAGE_HANDLER
   APP.send 'ready', {}


