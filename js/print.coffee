Mod.require 'Weya.Base',
 'Weya'
 'Wallapatta.Parser'
 (Base, Weya, Parser) ->

  class Static extends Base
   @initialize ->
    @elems =
     controls: (document.getElementsByClassName 'static-controls')[0]
     containers: document.getElementsByClassName 'wallapatta-container'
     docs: document.getElementsByClassName 'wallapatta'
     pageBackgrounds: (document.getElementsByClassName 'page-backgrounds')[0]
    @width = 170
    @height = 225

   render: ->
    Weya elem: @elems.controls, context: this, ->
     @$.elems.printForm = @div ".container.print-form", ->
      @form ->
       @label for: "width-input", "Width (mm)"
       @$.elems.widthInput = @input "#width-input.u-full-width",
        type: "number"
        value: "170"
       @label for: "height-input", "Height (mm)"
       @$.elems.heightInput = @input "#height-input.u-full-width",
        type: "number"
        value: "225"
       @div ->
        @button ".button-primary", "Preview",
         on: {click: @$.on.previewClick}
       @div ->
        @button ".button", "Print",
         on: {click: @$.on.printClick}

   @listen 'previewClick', (e) ->
    e.preventDefault()

    @width = parseInt @elems.widthInput.value
    @height = parseInt @elems.heightInput.value

    @preview()

   @listen 'printClick', (e) ->
    e.preventDefault()

    window.requestAnimationFrame ->
     window.print()

   _processDocument: (n, doc) ->
    code = doc.getElementsByClassName 'wallapatta-code'
    if code.length isnt 1
     throw new Error 'No code element'
    code = code[0]
    main = doc.getElementsByClassName 'wallapatta-main'
    if main.length isnt 1
     throw new Error 'No main element'
    main = main[0]
    sidebar = doc.getElementsByClassName 'wallapatta-sidebar'
    if sidebar.length isnt 1
     throw new Error 'No sidebar element'
    sidebar = sidebar[0]

    @_parsers[n] = parser = new Parser
     text: code.textContent
     id: n * 10000
    parser.parse()
    main.innerHTML = ''
    sidebar.innerHTML = ''
    @_renderers[n] = render = parser.getRender()
    render.render main, sidebar

    window.requestAnimationFrame =>
     render.mediaLoaded @on.documentLoaded

   @listen 'documentLoaded', ->
    @_documentsLoaded++

    return if @_documentsLoaded < @_parsers.length

    setTimeout @on.readyToSetPages, 1000

   @listen 'readyToSetPages', ->
    @elems.pageBackgrounds.innerHTML = ''
    for render in @_renderers
     pg = null
     Weya elem: @elems.pageBackgrounds, ->
      pg = @div ""
     render.setPageBackgrounds pg
     render.setPages @pageHeight, @pageWidth

    window.requestAnimationFrame @on.pagesSet

   @listen 'pagesSet', ->
    toc = []
    last = 1
    for render in @_renderers
     p = 0
     for pn in render.pageNumbers
      p = pn.page
      continue if not pn.node.type is 'section'
      continue if not pn.node.heading?
      toc.push
       page: pn.page + last
       level: pn.node.level
       heading: pn.node.heading.text
      console.log pn.page, pn.node.level, pn.node.heading.text
     last = last + p + 1

    pages = document.getElementsByClassName 'page-background'
    topMargin = @pageHeight + 10
    for page, i in pages
     Weya elem: page, ->
      @div ".page-number",
       style: {top: "#{topMargin}px"}
       "#{i + 1}"

    if window.RENDER_TOC?
     window.RENDER_TOC toc, @width

   preview: ->
    for container in @elems.containers
     container.classList.add 'wallapatta-print'
     container.style.width = "#{@width}mm"

    @_documentsLoaded = 0
    @_parsers = new Array @elems.docs.length
    @_renderers = new Array @elems.docs.length
    window.requestAnimationFrame =>
     ratio = @elems.containers[0].offsetWidth / @width
     @pageWidth = ratio * @width
     @pageHeight = ratio * @height
     for doc, i in @elems.docs
      @_processDocument i, doc





  STATIC = new Static()
  STATIC.render()


document.addEventListener 'DOMContentLoaded', ->
 Mod.set 'Weya', Weya
 Mod.set 'Weya.Base', Weya.Base
 Mod.set 'HLJS', hljs
 Mod.set 'CoffeeScript', 'CoffeeScript'

 Mod.initialize()
