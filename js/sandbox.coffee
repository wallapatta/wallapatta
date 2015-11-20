Mod.require 'Weya.Base',
 'Weya'
 'Editor'
 (Base, Weya, Editor) ->

  window.wallapattaDecodeURL = (url) ->
   res = url
   if res[0] isnt '/'
    res= "/#{res}"
   if APP.resources[res]?
    return APP.resources[res]
   else
    return url

  PARENT = parent

  class App extends Base
   @initialize ->
    @elems = {}
    @resources = {}
    @_changed = false
    @content = ''

   @listen 'addResource', (data) ->
    @resources[data.path] = data.dataURL

   loadRetainedFile: (callback) ->
      callback()

   send: (method, data) ->
    data.method = method
    PARENT.postMessage data, '*'

   @listen 'setText', (data) ->
    if data.saved
     @content = data.content
    Editor.setText data.content
    @_changed = false
    if not @_watchInterval?
     @_watchInterval = setInterval @on.watchChanges, 500

   @listen 'error', (e) ->
    console.error e

   @listen 'change', ->
    @send 'change', content: Editor.getText()

   render: ->
    setTimeout ->
     toolbar = document.getElementById 'toolbar'
     toolbar.style.display = 'none'
    , 300

   @listen 'print', ->
    Editor.on.print()

   removeTrailingSpace: (text) ->
    lines = text.split '\n'
    for line, i in lines
     lines[i] = line.trimRight()

    lines.join '\n'

   @listen 'save', ->
    text = @removeTrailingSpace Editor.getText()
    Editor.setText text
    @content = text
    @send 'saveFileContent', content: text

   @listen 'watchChanges', ->
    if Editor.getText() isnt @content
     if not @_changed
      @send 'fileChanged', changed: true
      @_changed = true
    else
     if @_changed
      @send 'fileChanged', changed: false
      @_changed = false



  APP = new App()
  APP.render()

  MESSAGE_HANDLER = (e) ->
   APP.on[e.data.method] e.data, e

  window.addEventListener 'message', MESSAGE_HANDLER

