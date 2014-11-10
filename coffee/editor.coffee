Mod.require 'Weya.Base',
 'CodeMirror'
 (Base) ->

  class Editor  extends Base
   @extend()

   template: ->
    @div ".container", ->
     @div ".row", ->
      @div ".col-md-12", ->
       @$.elems.textarea = @textarea ".editor",
        autocomplete: "off"
        spellcheck: "false"
     @div ".row", ->
      @div ".col-md-12", ->
       @$.elems.parse = @button ".btn.btn-default.btn-block",
        on: {click: @$.on.parse}
        "Render"
     @div ".row", ->
      @$.elems.preview = @div ".col-md-12", null

   @initialize ->
    @elems = {}

   @listen 'parse', (e) ->
    e.preventDefault()

    console.log "Parse", @editor.getValue()

   @listen 'setupEditor', ->
    @editor = CodeMirror.fromTextArea @elems.textarea,
     mode: "text"
     lineNumbers: true
     tabSize: 1

   render: ->
    @elems.container = document.body
    Weya elem: @elems.container, context: this, @template

    window.requestAnimationFrame @on.setupEditor

  editor = new Editor
  editor.render()
