Mod.require 'Weya.Base',
 'CodeMirror'
 'Wallapatta.Parser'
 'Wallapatta.Sample'
 'HLJS'
 (Base, CodeMirror, Parser, Sample, HLJS) ->

  class Editor  extends Base
   @extend()

   template: ->
    @div ".container.wallapatta-editor", ->
     @div ".row", ->
      @div ".five.columns", ->
        @$.elems.textarea = @textarea ".editor",
         autocomplete: "off"
         spellcheck: "false"
        @$.elems.parse = @button ".button-primary",
         on: {click: @$.on.parse}
         "Render"

      @$.elems.preview = @div ".preview.seven.columns", ->
       @$.elems.errors = @div ".row.error", null

       @div ".row.wallapatta", ->
        @$.elems.previewMain = @div ".nine.columns", null
        @$.elems.previewSidebar = @div ".three.columns", null

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

    try
     parser.parse()
    catch e
     @elems.errors.textContent = e.message
     return

    @elems.errors.textContent = ''
    render = parser.getRender()
    render.render @elems.previewMain, @elems.previewSidebar
    HLJS.initHighlighting()
    window.requestAnimationFrame ->
     render.mediaLoaded ->
      render.setFills()

   @listen 'setupEditor', ->
    @editor = CodeMirror.fromTextArea @elems.textarea,
     mode: "wallapatta"
     lineNumbers: true
     lineWrapping: true
     tabSize: 1
     foldGutter: true
     gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"]

    @editor.on 'change', @on.change
    height = window.innerHeight
    console.log height
    @editor.setSize null, "#{height - 120}px"
    @elems.preview.style.maxHeight = "#{height - 120}px"
    @editor.setValue Sample

   render: ->
    @elems.container = document.body
    Weya elem: @elems.container, context: this, @template

    window.requestAnimationFrame @on.setupEditor

  editor = new Editor
  editor.render()
