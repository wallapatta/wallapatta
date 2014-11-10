Mod.require 'Weya.Base',
 'CodeMirror'
 'Docscript.Parser'
 (Base, CodeMirror, Parser) ->

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
     @div ".row.docscript", ->
      @$.elems.previewMain = @div ".col-md-9", null
      @$.elems.previewSidebar = @div ".col-md-3", null

   @initialize ->
    @elems = {}

   @listen 'parse', (e) ->
    e.preventDefault()

    text = @editor.getValue()

    parser = new Parser text: text
    parser.parse()
    @elems.previewMain.innerHTML = ''
    @elems.previewSidebar.innerHTML = ''
    parser.render @elems.previewMain, @elems.previewSidebar

    console.log parser.root

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
