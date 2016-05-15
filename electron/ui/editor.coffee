Mod.require 'Weya.Base',
 'CodeMirror'
 'Wallapatta.Parser'
 'HLJS'
 (Base, CodeMirror, Parser, HLJS) ->

  decodeURL = (url) ->
   if window?.wallapattaDecodeURL?
    return window.wallapattaDecodeURL url
   else
    return url


  class Editor  extends Base
   @extend()

   toolbarTemplate: ->
    btn = (icon, event, title) ->
     @button ".btn.btn-default",
      title: title
      on: {click: @$.on[event]}
      ->
       @i ".fa.fa-#{icon}", null

    @div ".btn-group", ->
     btn.call this, 'header', 'header', 'Heading'

     btn.call this, 'bold', 'bold', 'bold'
     btn.call this, 'italic', 'italic', 'Italic'
     btn.call this, 'link', 'link', 'italic'
     btn.call this, 'code', 'inlineCode', 'ital'
     btn.call this, 'superscript', 'superscript', 'italic'
     btn.call this, 'subscript', 'subscript', 'italic'

    @div ".btn-group", ->
     btn.call this, 'table', 'table', 'italic'
     btn.call this, 'list-ol', 'listOl', 'italic'
     btn.call this, 'list-ul', 'listUl', 'italic'
     btn.call this, 'columns', 'sidenote', 'italic'
     btn.call this, 'camera', 'media', 'italic'

    @div ".btn-group", ->
     btn.call this, 'indent', 'indent', 'italic'
     btn.call this, 'outdent', 'outdent', 'italic'

    btn.call this, 'check', 'checkSpelling', 'italic'



   template: ->
    @$.elems.editorContainer = @div ".pane-group.wallapatta-editor", ->
     @div ".pane.editor-pane", ->
       @$.elems.textarea = @textarea ".editor",
        autocomplete: "off"
        spellcheck: "false"

     @$.elems.preview = @div ".pane.preview-pane", ->
      @$.elems.errors = @div ".error", null

      @div ".wallapatta", ->
       @$.elems.previewMain = @div ".wallapatta-main",
        on:
         click: @$.on.previewClick
         dblclick: @$.on.previewDbClick
       @$.elems.previewSidebar = @div ".wallapatta-sidebar",
        on:
         click: @$.on.previewClick
         dblclick: @$.on.previewDbClick

     @$.elems.pickMedia = @div ".pane.pick-media",
      style: {display: 'none'}, ->
       @$.elems.pickMediaList = @ul ".list-group",
        on: {click: @$.on.pickMediaClick}
       @button ".btn.btn-default", "Cancel", on: {click: @$.on.pickMediaCancel}


    @$.elems.printForm = @div ".print-form", style: {display: 'none'}, ->
     @form ->
      @div ".form-group", ->
       @label for: "width-input", "Width (mm)"
       @$.elems.widthInput = @input "#width-input.form-control",
        type: "number"
        value: "170"
      @div ".form-group", ->
       @label for: "height-input", "Height (mm)"
       @$.elems.heightInput = @input "#height-input.form-control",
        type: "number"
        value: "225"
      @div ".btn-group", ->
       @button ".btn.btn-primary", "Preview",
        on: {click: @$.on.renderPrintPreview}
       @button ".btn.btn-default", "Print",
        on: {click: @$.on.renderPrint}


    @$.elems.printContainer = @div ".editor-print",
      style: {display: 'none'}, ->
       @$.elems.pagePackgrounds = @div ".page-backgrounds", null
       @$.elems.wallapattaPrint =
        @div ".wallapatta-container.wallapatta-print", ->
         @$.elems.printDoc = @div ".wallapatta", ->
          @$.elems.printMain = @div ".wallapatta-main", null
          @$.elems.printSidebar = @div ".wallapatta-sidebar", null



   @initialize (options) ->
    @openUrl = options.openUrl ? (->)
    @onChangeListener = options.onChanged ? (->)
    @app = options.app
    @elems = {}
    @_isPrint = false

   @listen 'previewClick', (e) ->
    return if not @renderer?
    node = e.target
    while node? and node isnt document.body
     n = @renderer.getNodeFromElem node
     if n? and n.lineNumber
      @editor.setCursor line: n.lineNumber
      break
     node = node.parentNode

   @listen 'previewDbClick', (e) ->
    e.preventDefault()

    node = e.target
    while node? and node isnt document.body
     href = node.getAttribute 'href'
     if href?
      @openUrl href
      break
     node = node.parentNode

   @listen 'gutterClick', (cm, line, where, e) ->
    node = @renderer.getNodeFromLine line
    return if not node?
    elem = node.elem
    return if not elem?
    top = @renderer.getOffsetTop elem, @elems.preview
    @elems.preview.scrollTop = top

   @listen 'change', ->
    @preview()
    @onChangeListener()

   @listen 'parse', (e) ->
    e.preventDefault()
    @preview()

   wrapSelection: (b, e) ->
    s = @editor.getSelection()
    @editor.replaceSelection "#{b}#{s}#{e}"
    @editor.focus()

   addSegment: (b, e = '') ->
    s = @editor.getSelection()
    @editor.replaceSelection "\n#{b}#{s}#{e}\n"
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

   @listen 'media', ->
    @pickMediaPane()

   @listen 'sidenote', ->
    s = @editor.getSelection()
    @editor.replaceSelection "\n>>>\n#{s}"
    {line} = @editor.getCursor()
    @editor.indentLine line - 1, 'prev'
    @editor.indentLine line, 'prev'
    @editor.indentLine line, 'add'
    @editor.focus()

   @listen 'checkSpelling', ->
    window.CHECK_SPELLING = not window.CHECK_SPELLING

   print: ->
    @elems.editorContainer.style.display = 'none'
    @elems.printContainer.style.display = 'block'
    @elems.printForm.style.display = 'block'

   @listen 'renderPrint', (e) ->
    @on.renderPrintPreview e, true

   @listen 'renderPrintPreview', (e, print = false) ->
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
    @parser = new Parser text: text

    try
     @parser.parse()
    catch e
     @elems.errors.textContent = e.message
     return

    @elems.errors.textContent = ''
    render = @renderer = @parser.getRender()
    render.render @elems.printMain, @elems.printSidebar
    render.setPageBackgrounds @elems.pagePackgrounds
    @elems.wallapattaPrint.style.width = "#{WIDTH}mm"
    window.requestAnimationFrame =>
     ratio = @elems.printDoc.offsetWidth / WIDTH
     width = ratio * WIDTH
     height = ratio * HEIGHT
     render.mediaLoaded ->
      setTimeout ->
       render.setPages height, width
       if print
        setTimeout ->
         window.print()
        , 500
      , 500

   edit: ->
    @elems.editorContainer.style.display = 'flex'
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
    @parser = new Parser text: text

    try
     @parser.parse()
    catch e
     @elems.errors.textContent = e.message
     return

    @elems.errors.textContent = ''
    render = @renderer = @parser.getRender()
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
     styleActiveLine: true
     gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"]

    @editor.on 'change', @on.change
    height = window.innerHeight
    @editor.setSize null, "#{height - 100}px"
    @elems.preview.style.maxHeight = "#{height - 50}px"
    @editor.on 'gutterClick', @on.gutterClick

    window.addEventListener 'resize', @on.resize
    window.requestAnimationFrame @_onRendered

   @listen 'resize', ->
    height = window.innerHeight
    @editor.setSize null, "#{height - 100}px"
    @elems.preview.style.maxHeight = "#{height - 50}px"
    @preview()

   render: (elem, toolbar, callback) ->
    @_onRendered = callback
    @elems.container = elem
    @elems.toolbar = toolbar
    Weya elem: @elems.container, context: this, @template
    Weya elem: @elems.toolbar, context: this, @toolbarTemplate

    window.requestAnimationFrame @on.setupEditor

   @listen 'pickMediaClick', (e) ->
    @elems.pickMedia.style.display = 'none'
    @elems.preview.style.display = 'block'
    n = e.target
    path = null
    while n
     if n._path?
      path = n._path
      break
     n = n.parentNode

    if not path?
     return @addSegment '!image_url'

    #@wrapSelection "[[#{path}]]", ''
    return @addSegment "!#{path}(", ")"

   @listen 'pickMediaCancel', (e) ->
    @elems.pickMedia.style.display = 'none'
    @elems.preview.style.display = 'block'
    @editor.focus()

   pickMediaPane: ->
    if not @app?
     return @addSegment '!image_url'
    resources = @app.getResources()
    if not resources?
     return @addSegment '!image_url'

    @elems.pickMedia.style.display = 'block'
    @elems.preview.style.display = 'none'
    @elems.pickMediaList.innerHTML = ''

    Weya elem: @elems.pickMediaList, ->
     for path in resources
      @li ".list-group-item", data: {_path: path}, ->
       @img ".media-object.pull-left",
        src: (decodeURL path)
        width: 64
       @div ".media-body", ->
        @strong path




  Mod.set 'Editor', Editor
