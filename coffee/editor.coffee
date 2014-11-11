Mod.require 'Weya.Base',
 'CodeMirror'
 'Docscript.Parser'
 'Docscript.Sample'
 (Base, CodeMirror, Parser, Sample) ->

  class Editor  extends Base
   @extend()

   template: ->
    @div ".container-fluid", ->
     @div ".row-fluid", ->
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
     lineWrapping: true
     tabSize: 1
    @editor.on 'change', @on.change
    height = window.innerHeight
    console.log height
    @editor.setSize null, "#{height - 100}px"
    @editor.setValue Sample

   render: ->
    @elems.container = document.body
    Weya elem: @elems.container, context: this, @template

    window.requestAnimationFrame @on.setupEditor

  editor = new Editor
  editor.render()
