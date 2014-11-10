Mod.require 'Weya.Base',
 'Docscript.TYPES'
 'Docscript.Text'
 'Docscript.Block'
 'Docscript.Section'
 'Docscript.List'
 'Docscript.ListItem'
 'Docscript.Sidenote'
 'Docscript.Article'
 'Docscript.Media'
 'Docscript.Reader'
 (Base, TYPES, Text, Block, Section, List, ListItem, Sidenote, Article,
  Media, Reader) ->

   class Parser extends Base
    @extend()

    @initialize (options) ->
     @reader = new Reader options.text
     delete options.text
     @root = new Article indentation: 0
     @node = @root
     @main = true
     @sidenotes = []
     @prevBlock = null

    parse: ->
     while @reader.has()
      @process()
      @reader.next()

    addNode: (node) ->
     @node.add node
     @node = node

    getOffsetTop: (elem, parent) ->
     top = 0
     while elem?
      break if elem is parent
      top += elem.offsetTop
      elem = elem.offsetParent

     return top

    setFills: ->
     for sidenote in @sidenotes
      elemSidenote = sidenote.elem
      elemContent = @nodes[sidenote.link].elem

      topSidenote = @getOffsetTop elemSidenote, @elems.sidebar
      topContent = @getOffsetTop elemContent, @elems.main

      if topContent > topSidenote
       fill = Weya {}, ->
        @div ".fill", style: {height: "#{topContent - topSidenote}px"}

       elemSidenote.parentNode.insertBefore fill, elemSidenote
      else if topContent < topSidenote
       fill = Weya {}, ->
        @div ".fill", style: {height: "#{topSidenote - topContent}px"}

       elemContent.parentNode.insertBefore fill, elemContent


    render: (main, sidebar) ->
     @elems =
      main: main
      sidebar: sidebar

     @nodes = {}
     @root.render elem: main, nodes: @nodes

     for sidenote in @sidenotes
      sidenote.render elem: sidebar, nodes: @nodes

     window.requestAnimationFrame @on.rendered

    @listen 'rendered', ->
     n = 0

     loaded = =>
      n--

      if n is 0
       @setFills()

     for id of @nodes
      n++

     for id, node of @nodes
      node.onLoaded loaded



    process: ->
     line = @reader.get()

     if line.empty
      if @node.type is TYPES.block
       @prevBlock = @node
       @node = @node.parent()

      return



     while line.indentation < @node.indentation
      @node = @node.parent()
      if not @node?
       throw new Error 'Invalid indentation'

     switch line.type
      when TYPES.code
       #TODO
       @addNode new Code indentation: 0

      when TYPES.list
       if @node.type isnt TYPES.list
        @addNode new List ordered: line.ordered, indentation: line.indentation

       @addNode new ListItem ordered: line.ordered, indentation: line.indentation + 1
       if line.text isnt ''
        @addNode new Block indentation: line.indentation + 1, paragraph: false
        @node.addText line.text

      when TYPES.heading
       @addNode new Section indentation: line.indentation + 1, level: line.level
       @node.heading.addText line.text

      when TYPES.sidenote
       if @main
        @main = false
        id = @node.id
        console.log 'sidenote', id
        id = @prevBlock.id if @prevBlock?
        console.log 'sidenote', id
        n = new Sidenote indentation: line.indentation, link: id
        @mainNode = @node
        @node = n
        @sidenotes.push n
       else
        @main = true
        @node = @mainNode

      when TYPES.block
       if @node.type isnt TYPES.block
        @addNode new Block indentation: line.indentation, paragraph: true
       @node.addText line.text

      when TYPES.media
       @addNode new Media indentation: line.indentation + 1, media: @parseMedia line.text
       @prevBlock = @node
       return

      else
       throw new Error 'Unknown syntax'

     @prevBlock = null

    parseMedia: (text) ->
     text = text.replace /\)/g, ''
     parts = text.split '('

     media = {}
     if parts.length <= 0
      throw new Error 'Invalid media syntax'

     media.src = parts[0]

     return media if parts.length <= 1

     media.alt = parts[1]

     return media




   Mod.set 'Docscript.Parser', Parser

