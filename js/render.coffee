Mod.require 'Weya.Base',
 'Wallapatta.TYPES'
 (Base, TYPES) ->

   PREFIX = 'wallapatta_'

   class Render extends Base
    @initialize (options) ->
     @map = options.map
     @root = options.root
     @sidenotes = options.sidenotes

    getOffsetTop: (elem, parent) ->
     top = 0
     while elem?
      break if elem is parent
      top += elem.offsetTop
      elem = elem.offsetParent

     return top

    setPages: (H) ->
     page = 0
     for sidenote in @sidenotes
      elemSidenote = sidenote.elem
      elemContent = @map.nodes[sidenote.link].elem

      topSidenote = @getOffsetTop elemSidenote, @elems.sidebar
      topContent = @getOffsetTop elemContent, @elems.main

      if topContent > topSidenote
       fill = Weya {}, ->
        @div ".fill", style: {height: "1px"}

       elemSidenote.parentNode.insertBefore fill, elemSidenote
      else if topContent < topSidenote
       fill = Weya {}, ->
        @div ".fill", style: {height: "1px"}

       elemContent.parentNode.insertBefore fill, elemContent

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


    setFills: ->
     for sidenote in @sidenotes
      elemSidenote = sidenote.elem
      elemContent = @map.nodes[sidenote.link].elem

      topSidenote = @getOffsetTop elemSidenote, @elems.sidebar
      topContent = @getOffsetTop elemContent, @elems.main

      if topContent > topSidenote
       fill = Weya {}, ->
        @div ".fill", style: {height: "1px"}

       elemSidenote.parentNode.insertBefore fill, elemSidenote
      else if topContent < topSidenote
       fill = Weya {}, ->
        @div ".fill", style: {height: "1px"}

       elemContent.parentNode.insertBefore fill, elemContent

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

     @root.render elem: main

     for sidenote in @sidenotes
      sidenote.render elem: sidebar

    collectElements: (options) ->
     @elems =
      main: options.main
      sidebar: options.sidebar

     for id, node of @map.nodes
      node.elem = document.getElementById "#{PREFIX}#{id}"
      if not node.elem?
       throw new Error "Element #{id} not found"

    mediaLoaded: (callback) ->
     mainImg = @elems.main.getElementsByTagName 'img'
     sidebarImg = @elems.sidebar.getElementsByTagName 'img'
     a = []
     a.push i for i in mainImg
     a.push i for i in sidebarImg

     n = 0
     check = =>
      if n is a.length
       callback()

     loaded = ->
      n++
      check()

     for img in a
      if not img.complete
       img.addEventListener 'load', loaded
      else
       n++

     check()


    processLine: ->
     line = @reader.get()

     if line.empty
      if @node.type is TYPES.block
       @prevNode = @node
       @node = @node.parent()

      if @node.type is TYPES.codeBlock or @node.type is TYPES.html
       @node.addText line.line.substr @node.indentation

      return


     while line.indentation < @node.indentation
      @prevNode = @node
      @node = @node.parent()
      if not @node?
       if @main
        throw new Error 'Invalid indentation'

       @main = true
       @node = @mainNode

     @prevNode ?= @node

     switch @node.type
      when TYPES.list
       if line.type isnt TYPES.list
        @node = @node.parent()

      when  TYPES.codeBlock, TYPES.html
       @node.addText line.line.substr @node.indentation
       return

     switch line.type
      when TYPES.codeBlock
       indent = line.indentation + 1
       @addNode new CodeBlock map: @map, indentation: line.indentation + 1
       while false
        @reader.next()
        break unless @reader.has()
        line = @reader.get()
        if not line.empty and line.indentation < indent
         indent = line.indentation
        break if line.type is TYPES.codeBlock
        @node.addText line.line.substr indent

      when TYPES.html
       indent = line.indentation + 1
       @addNode new Html map: @map, indentation: line.indentation + 1
       while false
        @reader.next()
        break unless @reader.has()
        line = @reader.get()
        if not line.empty and line.indentation < indent
         indent = line.indentation
        break if line.type is TYPES.html
        @node.addText line.line.substr indent


      when TYPES.special
       @addNode new Special map: @map, indentation: line.indentation + 1

      when TYPES.list
       if @node.type isnt TYPES.list
        @addNode new List map: @map, ordered: line.ordered, indentation: line.indentation

       @addNode new ListItem map: @map, ordered: line.ordered, indentation: line.indentation + 1
       if line.text isnt ''
        @addNode new Block map: @map, indentation: line.indentation + 1, paragraph: false
        @node.addText line.text

      when TYPES.heading
       @addNode new Section map: @map, indentation: line.indentation + 1, level: line.level
       @node.heading.addText line.text
       @blocks.push @node.heading

      when TYPES.sidenote
       if not @main
        throw new Error 'Cannot have a sidenote inside a sidenote'

       @main = false
       id = @node.id
       id = @prevNode.id if @prevNode?
       n = new Sidenote map: @map, indentation: line.indentation + 1, link: id
       @mainNode = @node
       @node = n
       @sidenotes.push n

      when TYPES.block
       if @node.type isnt TYPES.block
        @addNode new Block map: @map, indentation: line.indentation, paragraph: true
       @node.addText line.text

      when TYPES.media
       @addNode new Media map: @map, indentation: line.indentation + 1, media: @parseMedia line.text
       @prevNode = @node
       return

      else
       throw new Error 'Unknown syntax'


    parseLink: (text) ->
     text = text.replace /\)/g, ''
     parts = text.split '('

     link = {}
     if parts.length <= 0 or parts[0] is ''
      throw new Error 'Invalid media syntax'

     link.link = parts[0].trim()
     return link if parts.length <= 1
     link.text = parts[1].trim()
     return link

    parseMedia: (text) ->
     text = text.replace /\)/g, ''
     parts = text.split '('

     media = {}
     if parts.length <= 0 or parts[0] is ''
      throw new Error 'Invalid media syntax'

     media.src = parts[0].trim()
     return media if parts.length <= 1
     media.alt = parts[1].trim()
     return media




   Mod.set 'Wallapatta.Render', Render

