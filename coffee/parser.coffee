Mod.require 'Weya.Base',
 'Docscript.TYPES'

 'Docscript.Text'
 'Docscript.Bold'
 'Docscript.Italics'
 'Docscript.SuperScript'
 'Docscript.SubScript'
 'Docscript.Code'
 'Docscript.Link'

 'Docscript.Block'
 'Docscript.Section'
 'Docscript.List'
 'Docscript.ListItem'
 'Docscript.Sidenote'
 'Docscript.Article'
 'Docscript.Media'

 'Docscript.CodeBlock'
 'Docscript.Special'
 'Docscript.Html'

 'Docscript.NODES'

 'Docscript.Reader'
 (Base, TYPES,
  Text, Bold, Italics, SuperScript, SubScript, Code, Link,
  Block, Section, List, ListItem, Sidenote, Article, Media,
  CodeBlock, Special, Html,
  NODES, Reader) ->

   PREFIX = 'docscript_'

   TOKENS =
    bold: Bold
    italics: Italics
    superScript: SuperScript
    subScript: SubScript

   TOKEN_MATCHES =
    bold: '**'
    italics: '--'
    subScript: '__'
    superScript: '^^'
    code: '``'
    linkBegin: '<<'
    linkEnd: '>>'

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
     @blocks = []

    parse: ->
     while @reader.has()
      try
       @processLine()
      catch e
       throw e
       #throw new Error "Line #{@reader.n + 1}: #{e.message}"

      @reader.next()

     for block in @blocks
      try
       @parseText block.text, block
      catch e
       throw new Error "#{e.message}: \"#{block.text}\""

    getToken: (text, n) ->
     for token, match of TOKEN_MATCHES
      if (text.substr n, match.length) is match
       return type: token, length: match.length

     return null

    parseText: (text, node) ->
     @node = node
     L = text.length
     last = i = 0
     cur = 0

     add = =>
      if cur > last
       @addNode new Text text: text.substr last, cur - last
       @node = @node.parent()

     while i < L
      token = @getToken text, i

      if token?
       cur = i
       i += token.length
      else
       ++i
       continue

      if TOKENS[token.type]?
       if @node.type is token.type
        add()
        @node = @node.parent()
       else
        add()
        @addNode new TOKENS[token.type] {}

      else
       switch token.type
        when 'linkBegin'
          add()
          @addNode new Link {}

        when 'linkEnd'
         if @node.type isnt TYPES.link
          throw new Error 'Unexpected link terminator'
         else
          @node.setLink @parseLink text.substr last, cur - last
          @node = @node.parent()

        when 'code'
         add()
         @addNode new Code {}
         last = i
         cur = i = text.indexOf TOKEN_MATCHES.code, i
         add()
         @node = @node.parent()
         i += TOKEN_MATCHES.code.length


      last = i

     cur = i
     add()


    addNode: (node) ->
     @node.add node
     if node.type is TYPES.block
      @blocks.push node
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
      elemContent = NODES[sidenote.link].elem

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

     for id, node of NODES
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
       @prevBlock = @node
       @node = @node.parent()

      return



     while line.indentation < @node.indentation
      @node = @node.parent()
      if not @node?
       throw new Error 'Invalid indentation'

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
       @addNode new CodeBlock indentation: line.indentation + 1
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
       @addNode new Html indentation: line.indentation + 1
       while false
        @reader.next()
        break unless @reader.has()
        line = @reader.get()
        if not line.empty and line.indentation < indent
         indent = line.indentation
        break if line.type is TYPES.html
        @node.addText line.line.substr indent


      when TYPES.special
       @addNode new Special indentation: line.indentation + 1

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
       @blocks.push @node.heading

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




   Mod.set 'Docscript.Parser', Parser

