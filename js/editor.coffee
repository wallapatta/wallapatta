Mod.require 'Weya.Base',
 'CodeMirror'
 'Wallapatta.Parser'
 'Wallapatta.Sample'
 'HLJS'
 (Base, CodeMirror, Parser, Sample, HLJS) ->

  class Editor  extends Base
   @extend()

   template: ->
    @$.elems.editorContainer = @div ".container.wallapatta-editor", ->
     @div ".row", ->
      @div ".five.columns", ->
        @div ".toolbar", ->
         @div "#toolbar", ->
          @i ".fa.fa-print", on: {click: @$.on.print}

         @div ->
          @i ".fa.fa-header", on: {click: @$.on.header}

          @i ".fa.fa-bold", on: {click: @$.on.bold}
          @i ".fa.fa-italic", on: {click: @$.on.italic}
          @i ".fa.fa-link", on: {click: @$.on.link}
          @i ".fa.fa-code", on: {click: @$.on.inlineCode}
          @i ".fa.fa-camera", on: {click: @$.on.inlineMedia}
          @i ".fa.fa-superscript", on: {click: @$.on.superscript}
          @i ".fa.fa-subscript", on: {click: @$.on.subscript}

          @i ".fa.fa-table", on: {click: @$.on.table}

          @i ".fa.fa-list-ol", on: {click: @$.on.listOl}
          @i ".fa.fa-list-ul", on: {click: @$.on.listUl}

          @i ".fa.fa-indent", on: {click: @$.on.indent}
          @i ".fa.fa-outdent", on: {click: @$.on.outdent}

          @i ".fa.fa-columns", on: {click: @$.on.sidenote}


        @$.elems.textarea = @textarea ".editor",
         autocomplete: "off"
         spellcheck: "false"

      @$.elems.preview = @div ".preview.seven.columns", ->
       @$.elems.errors = @div ".row.error", null

       @div ".row.wallapatta", ->
        @$.elems.previewMain = @div ".nine.columns", null
        @$.elems.previewSidebar = @div ".three.columns", null

    @$.elems.printForm = @div ".container.print-form", style: {display: 'none'}, ->
     @form ->
      @button "Edit",
       on: {click: @$.on.closePrint}
      @div ".row", ->
       @div ".six.columns", ->
        @label for: "width-input", "Width (mm)"
        @$.elems.widthInput = @input "#width-input.u-full-width",
         type: "number"
         value: "170"
        @label for: "height-input", "Height (mm)"
        @$.elems.heightInput = @input "#height-input.u-full-width",
         type: "number"
         value: "225"
        @button ".button-primary", "Print",
         on: {click: @$.on.renderPrint}


    @$.elems.printContainer = @div ".container.wallapatta-container.wallapatta-print", ->
     @$.elems.printDoc = @div ".row.wallapatta", ->
      @$.elems.printMain = @div ".nine.columns", null
      @$.elems.printSidebar = @div ".three.columns", null



   @initialize ->
    @elems = {}
    @_isPrint = false

   @listen 'change', ->
    @preview()
    @onChangeListener?()

   @listen 'parse', (e) ->
    e.preventDefault()
    @preview()

   wrapSelection: (b, e) ->
    s = @editor.getSelection()
    @editor.replaceSelection "#{b}#{s}#{e}"
    @editor.focus()

   addSegment: (b) ->
    s = @editor.getSelection()
    @editor.replaceSelection "\n#{b}#{s}\n"
    {line} = @editor.getCursor()
    @editor.indentLine line - 1, 'prev'
    @editor.indentLine line, 'prev'
    @editor.indentLine line, 'add'
    @editor.focus()


   @listen 'header', ->
    @addSegment '#'

   @listen 'bold', -> @wrapSelection '**', '**'
   @listen 'italic', -> @wrapSelection '--', '--'
   @listen 'inlineCode', -> @wrapSelection '``', '``'
   @listen 'link', -> @wrapSelection '<<', '>>'
   @listen 'inlineMedia', -> @wrapSelection '[[', ']]'
   @listen 'superscript', -> @wrapSelection '^^', '^^'
   @listen 'subscript', -> @wrapSelection '__', '__'

   @listen 'table', ->
    s = @editor.getSelection()
    @editor.replaceSelection "\n|||\ncol1|col2\n===\n1,1|1,2\n2,1|2,2\n#{s}"
    {line} = @editor.getCursor()
    @editor.indentLine line - 5, 'prev'
    @editor.indentLine line - 4, 'prev'
    @editor.indentLine line - 4, 'add'
    @editor.indentLine line - 3, 'prev'
    @editor.indentLine line - 2, 'prev'
    @editor.indentLine line - 1, 'prev'
    @editor.indentLine line, 'prev'
    @editor.indentLine line, 'subtract'
    @editor.focus()

   @listen 'indent', ->
    sels = @editor.listSelections()
    for sel in sels
     for i in [sel.anchor.line..sel.head.line]
      @editor.indentLine i, 'add'

   @listen 'outdent', ->
    sels = @editor.listSelections()
    for sel in sels
     for i in [sel.anchor.line..sel.head.line]
      @editor.indentLine i, 'subtract'

   @listen 'listOl', -> @addSegment '- '
   @listen 'listUl', -> @addSegment '* '

   @listen 'sidenote', ->
    s = @editor.getSelection()
    @editor.replaceSelection "\n>>>\n#{s}"
    {line} = @editor.getCursor()
    @editor.indentLine line - 1, 'prev'
    @editor.indentLine line, 'prev'
    @editor.indentLine line, 'add'
    @editor.focus()


   @listen 'print', ->
    @elems.editorContainer.classList.add 'wallapatta-editor-print'
    @elems.printContainer.style.display = 'block'
    @elems.printForm.style.display = 'block'

   @listen 'renderPrint', (e) ->
    e.preventDefault()
    WIDTH = parseInt @elems.widthInput.value
    if isNaN WIDTH
     WIDTH = 170
    HEIGHT = parseInt @elems.heightInput.value
    if isNaN HEIGHT
     HEIGHT = 225
    text = @editor.getValue()

    @elems.printMain.innerHTML = ''
    @elems.printSidebar.innerHTML = ''
    parser = new Parser text: text

    try
     parser.parse()
    catch e
     @elems.errors.textContent = e.message
     return

    @elems.errors.textContent = ''
    render = parser.getRender()
    render.render @elems.printMain, @elems.printSidebar
    @elems.printContainer.style.width = "#{WIDTH}mm"
    window.requestAnimationFrame =>
     ratio = @elems.printDoc.offsetWidth / WIDTH
     width = ratio * WIDTH
     height = ratio * HEIGHT
     render.mediaLoaded ->
      setTimeout ->
       render.setPages height, width
       window.requestAnimationFrame ->
        window.print()
      , 500

   @listen 'closePrint', ->
    @elems.editorContainer.classList.remove 'wallapatta-editor-print'
    @elems.printContainer.style.display = 'none'
    @elems.printForm.style.display = 'none'

   setText: (text) ->
    @editor.setValue text

   getText: ->
    @editor.getValue()

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
    window.requestAnimationFrame ->
     render.mediaLoaded ->
      render.setFills()

   @listen 'setupEditor', ->
    @editor = CodeMirror.fromTextArea @elems.textarea,
     mode: "wallapatta"
     lineNumbers: true
     lineWrapping: true
     tabSize: 1
     indentUnit: 1
     foldGutter: true
     gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"]

    @editor.on 'change', @on.change
    height = window.innerHeight
    @editor.setSize null, "#{height - 100}px"
    @elems.preview.style.maxHeight = "#{height - 50}px"
    @editor.setValue Sample

    window.addEventListener 'resize', @on.resize
    window.requestAnimationFrame @_onRendered

   @listen 'resize', ->
    height = window.innerHeight
    @editor.setSize null, "#{height - 100}px"
    @elems.preview.style.maxHeight = "#{height - 50}px"

   render: (callback) ->
    @_onRendered = callback
    @elems.container = document.body
    Weya elem: @elems.container, context: this, @template

    window.requestAnimationFrame @on.setupEditor

  EDITOR = new Editor
  EDITOR.render ->
   Mod.set 'Editor', EDITOR
