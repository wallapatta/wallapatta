Mod.require 'Weya.Base',
 'Wallapatta.TYPES'
 (Base, TYPES) ->

   PREFIX = 'wallapatta_'

   INF = 1e10

   PAGE_COST = 100
   BREAK_COST =
    codeBlock: 1000
    special: 1000
    html: 1000
    heading: 2000
    list: 1000
    listItem: 1500
    block: 1500
    media: 1000
    article: 0

   PAGE_MARGIN = '1000px'
   START = 1


   class Render extends Base
    @initialize (options) ->
     @map = options.map
     @root = options.root
     @sidenotes = options.sidenotes

    getBreakCost: (node) ->
     if @breakCostMap[node.id]?
      return @breakCostMap[node.id]

     if node.parent()?
      cost = @getBreakCost node.parent(), true
     else
      if node.type isnt 'article'
       throw new Error 'oops'
      cost = 0

     if BREAK_COST[node.type]?
      @breakCostMap[node.id] = cost + BREAK_COST[node.type]
     else if node.type is 'section'
      @breakCostMap[node.id] = cost + 100 * (node.level - 2)
     else
      throw new Error 'Unknown type'

     return @breakCostMap[node.id]


    getOffsetTop: (elem, parent) ->
     top = 0
     while elem?
      break if elem is parent
      top += elem.offsetTop
      elem = elem.offsetParent

     return top

    getMainNodes: ->
     f = @map.start
     e = @map.N

     nodes = []
     for i in [f...e]
      elem = @map.nodes[i].elem
      main = false
      while elem?
       if elem is @elems.main
        main = true
        break
       elem = elem.parentNode
      nodes.push i if main

     return nodes

    getSidenoteMap: ->
     map = {}
     for sidenote in @sidenotes
      map[sidenote.link] = sidenote.id

     return map

    calculateNextBreak: (n) ->
     m = @mainNodes[n]
     node = @map.nodes[m]
     elem = node.elem
     H = @pageHeight
     if n is 1
      H -= @getOffsetTop elem, null

     i = n + 1
     sidenote = 0
     padding = 0
     if @sidenoteMap[m]?
      sidenote = @map.nodes[@sidenoteMap[m]].elem.offsetHeight

     while i < @mainNodes.length
      j = @mainNodes[i]
      inode = @map.nodes[j]
      ielem = inode.elem
      pos = padding +
            (@getOffsetTop ielem, @elems.main) -
            (@getOffsetTop elem, @elems.main)
      break if pos > H

      c = @broken[i] + @breakCost[i] + PAGE_COST
      if @broken[n] >= c
       @broken[n] = c
       @nextBreak[n] = i

      if @sidenoteMap[j]?
       p = Math.max 0, sidenote - pos
       padding += p
       pos += p
       sidenote = pos + @map.nodes[@sidenoteMap[j]].elem.offsetHeight

      break if sidenote > H
      ++i

     if i >= @mainNodes.length
      @broken[n] = 0
      @nextBreak[n] = null


    calculatePageBreaks: ->
     INF = 1e10
     @broken = []
     @nextBreak = []
     for i in @mainNodes
      @broken.push INF
      @nextBreak.push null

     @breakCostMap = {}
     @breakCost = []

     for i in @mainNodes
      @breakCost.push @getBreakCost @map.nodes[i]

     n = @mainNodes.length - 1
     while n >= 1
      @calculateNextBreak n
      --n

    adjust: (elemSidenote, elemContent) ->
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



    setPages: (H) ->
     #@setFills()
     #return
     @pageHeight = H
     @mainNodes = @getMainNodes()
     @sidenoteMap =  @getSidenoteMap()
     @calculatePageBreaks()

     n = START
     pos = 0
     emptyPages = []
     while n < @mainNodes.length
      i = @nextBreak[n]

      if n > START
       m = @mainNodes[n]
       node = @map.nodes[m]
       elem = node.elem
       elem.style.marginTop = PAGE_MARGIN

      i = @mainNodes.length unless i?
      found = @setPageFill n, i, pos, emptyPages
      if not found
       emptyPages.push pos: pos, f: n
      else
       emptyPages = []
      elem = @map.nodes[@mainNodes[i - 1]].elem
      pos = @getOffsetTop elem, @elems.main
      pos += elem.offsetHeight
      n = i

    setPageFill: (f, t, pos, emptyPages) ->
     margin = (f > START)
     first = true
     n = f
     found = false
     while n < t
      m = @mainNodes[n]
      s = @sidenoteMap[m]
      ++n
      continue unless s?
      found = true

      elemSidenote = @map.nodes[s].elem
      elemContent = @map.nodes[m].elem

      if first and margin
       for p in emptyPages
        topSidenote = @getOffsetTop elemSidenote, @elems.sidebar
        if topSidenote < p
         fill = Weya {}, ->
          @div ".fill", style: {height: "#{p.pos - topSidenote}px"}
         elemSidenote.parentNode.insertBefore fill, elemSidenote

        topContent = @getOffsetTop @map.nodes[@mainNodes[p.f]].elem, @elems.main
        topSidenote = @getOffsetTop elemSidenote, @elems.sidebar
        fill = Weya {}, ->
         @div ".fill", style: {height: "16px"}
        fill.style.marginTop = "#{topContent - topSidenote}px"
        elemSidenote.parentNode.insertBefore fill, elemSidenote

       #Current Page
       topSidenote = @getOffsetTop elemSidenote, @elems.sidebar
       if topSidenote < pos
        fill = Weya {}, ->
         @div ".fill", style: {height: "#{pos - topSidenote}px"}
        elemSidenote.parentNode.insertBefore fill, elemSidenote

       topContent = @getOffsetTop @map.nodes[@mainNodes[f]].elem, @elems.main
       topSidenote = @getOffsetTop elemSidenote, @elems.sidebar
       fill = Weya {}, ->
        @div ".fill", style: {height: "1px"}
       fill.style.marginTop = "#{topContent - topSidenote - 1}px"
       elemSidenote.parentNode.insertBefore fill, elemSidenote

      @adjust elemSidenote, elemContent

     return found


    setFills: ->
     for sidenote in @sidenotes
      elemSidenote = sidenote.elem
      elemContent = @map.nodes[sidenote.link].elem

      @adjust elemSidenote, elemContent


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

