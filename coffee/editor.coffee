Mod.require 'Weya.Base',
 'CodeMirror'
 'Docscript.Parser'
 (Base, CodeMirror, Parser) ->

  class Editor  extends Base
   @extend()

   template: ->
    @div ".container-fluid", ->
     @div ".row", ->
      @div ".col-md-5", ->
       @$.elems.textarea = @textarea ".editor",
        autocomplete: "off"
        spellcheck: "false"
       @$.elems.parse = @button ".btn.btn-default.btn-block",
        on: {click: @$.on.parse}
        "Render"
      @div ".col-md-7", ->
       @div ".row.docscript", ->
        @$.elems.previewMain = @div ".col-md-9", null
        @$.elems.previewSidebar = @div ".col-md-3", null

   @initialize ->
    @elems = {}

   @listen 'change', ->
    @preview()

   @listen 'parse', (e) ->
    e.preventDefault()
    @preview()

   preview: ->
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
    @editor.on 'change', @on.change

   render: ->
    @elems.container = document.body
    Weya elem: @elems.container, context: this, @template

    window.requestAnimationFrame @on.setupEditor

  editor = new Editor
  editor.render()
