Mod.require 'Weya.Base',
 'Wallapatta.TYPES'
 (Base, TYPES) ->

   PREFIX = 'wallapatta_'
   BLOCK_LEVEL = 10

   INF = 1e10

   PAGE_COST = 100
   BREAK_COST =
    codeBlock: 1000
    special: 2000
    full: 2000
    html: 1000
    heading: 2000
    list: 1000
    listItem: 1500
    block: 1500
    media: 1000
    article: 0
    table: 1500
   SECTION_BREAK_COST =
    1: 25
    2: 36
    3: 52
    4: 75
    5: 108
    6: 155
    "#{BLOCK_LEVEL}": 1000



   PARENT_POSITION_COST = 500
   EMPTY_PAGE_COST = 200

   PAGE_MARGIN = '1000px'
   START = 1


   class Render extends Base
    @initialize (options) ->
     @map = options.map
     @root = options.root
     @sidenotes = options.sidenotes

    _emptyPageCost: (filled, height) ->
     p = filled / height
     p = Math.max p, 0.01
     #p = Math.sqrt p
     p = Math.min 1, p
     return EMPTY_PAGE_COST * (1 / p - 1)

    _parentPositionCost: (pos) ->
     p = pos / @pageHeight
     p = Math.max p, 0.01
     #p = Math.sqrt p
     p = Math.min 1, p
     return PARENT_POSITION_COST * (1 / p - 1)


    getNodeBreakCost: (node) ->
     if BREAK_COST[node.type]?
      return BREAK_COST[node.type]
     else if node.type is 'section' and SECTION_BREAK_COST[node.level]?
      return SECTION_BREAK_COST[node.level]
     else
      throw new Error "Unknown type #{node.type} - #{node.level}"

    getBreakCost: (node) ->
     parent = node.parent()
     cost = 0

     while parent?
      cost += @getNodeBreakCost parent
      pos = (@getOffsetTop node.elem, @elems.main) -
            (@getOffsetTop parent.elem, @elems.main)
      cost += @_parentPositionCost pos
      parent = parent.parent()

     return cost

    getOffsetTop: (elem, parent) ->
     top = 0
     while elem?
      break if elem is parent
      top += elem.offsetTop
      elem = elem.offsetParent

     return top

    getNodeFromElem: (elem) ->
     #TODO
     id = elem.id
     return null if not id?
     id = id.split '_'
     return null if id.length < 1
     id = id[id.length - 1]
     node = @map.nodes[id]
     return node

    getNodeFromLine: (line) ->
     id = @map.lineNumbers[line]
     return null if not id?
     return @map.nodes[id]

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
      if H <= @pageHeight / 2
       H = @pageHeight

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

      c = @broken[i] + @breakCost[i] + PAGE_COST + @_emptyPageCost pos, H
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
      if not ielem? or pos + ielem.offsetHeight <= H
       @broken[n] = 0
       @nextBreak[n] = null


    calculatePageBreaks: ->
     INF = 1e10
     @broken = []
     @nextBreak = []
     for i in @mainNodes
      @broken.push INF
      @nextBreak.push null

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



    addPageBackground: (H, W, elem) ->
     y = @getOffsetTop elem, document.body
     pg = null
     Weya elem: @elems.pageBackgrounds, ->
      pg = @div ".page-background", "", style:
       'margin-top': "0"
       height: "#{H}px"
       width: "#{W}px"

     y2 = @getOffsetTop pg, document.body
     pg.style.marginTop = "#{y - y2}px"

    setPageBackgrounds: (elem) ->
     @elems.pageBackgrounds = elem

    setPages: (H, W) ->
     #@setFills()
     #return
     @pageHeight = H
     @mainNodes = @getMainNodes()
     @sidenoteMap =  @getSidenoteMap()
     @calculatePageBreaks()
     if not @elems.pageBackgrounds?
      Weya elem: document.body, context: this, ->
       @$.elems.pageBackgrounds = @div ".page-backgrounds", ''

     @elems.pageBackgrounds.innerHTML = ''

     n = START
     pos = 0
     emptyPages = []
     @pageNumbers = []
     pageNo = 0
     while n < @mainNodes.length
      i = @nextBreak[n]

      if n > START
       m = @mainNodes[n]
       node = @map.nodes[m]
       elem = node.elem
       elem.style.marginTop = PAGE_MARGIN

      i = @mainNodes.length unless i?
      found = @setPageFill n, i, pos, emptyPages, pageNo
      @collectPageNumbers n, i, pageNo
      if not found
       emptyPages.push pos: pos, f: n
      else
       emptyPages = []
      elem = @map.nodes[@mainNodes[i - 1]].elem
      pos = @getOffsetTop elem, @elems.main
      pos += elem.offsetHeight
      @addPageBackground H, W, @map.nodes[@mainNodes[n]].elem

      n = i
      pageNo++

    collectPageNumbers: (f, t, pageNo) ->
     for n in [f...t]
      m = @mainNodes[n]
      continue if not m?
      @pageNumbers.push
       page: pageNo
       node: @map.nodes[m]

    setPageFill: (f, t, pos, emptyPages, pageNo) ->
     margin = (f > START)
     first = true
     n = f
     found = false
     while n < t
      m = @mainNodes[n]
      ++n
      continue unless m?
      s = @sidenoteMap[m]
      continue unless s?
      found = true

      elemSidenote = @map.nodes[s].elem
      elemContent = @map.nodes[m].elem

      if first and margin
       for p in emptyPages
        topSidenote = @getOffsetTop elemSidenote, @elems.sidebar
        if topSidenote < p.pos
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
      first = false

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





   Mod.set 'Wallapatta.Render', Render

