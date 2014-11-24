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
      @$.elems.preview = @div ".preview.col-md-7", ->
       @div ".row.error", ->
        @$.elems.errors = @div ".col-md-12", null

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

    @elems.previewMain.innerHTML = ''
    @elems.previewSidebar.innerHTML = ''
    parser = new Parser text: text

    #parser.parse()
    try
     parser.parse()
    catch e
     @elems.errors.textContent = e.message
     return

    @elems.errors.textContent = ''
    parser.render @elems.previewMain, @elems.previewSidebar
    window.requestAnimationFrame ->
     parser.mediaLoaded ->
      parser.setFills()

   @listen 'setupEditor', ->
    @editor = CodeMirror.fromTextArea @elems.textarea,
     mode: "docscript"
     lineNumbers: true
     lineWrapping: true
     tabSize: 1
    @editor.on 'change', @on.change
    height = window.innerHeight
    console.log height
    @editor.setSize null, "#{height - 100}px"
    @elems.preview.style.maxHeight = "#{height - 100}px"
    @editor.setValue Sample

   render: ->
    @elems.container = document.body
    Weya elem: @elems.container, context: this, @template

    window.requestAnimationFrame @on.setupEditor

  editor = new Editor
  editor.render()
