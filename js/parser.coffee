Mod.require 'Weya.Base',
 'Wallapatta.TYPES'

 'Wallapatta.Text'
 'Wallapatta.Bold'
 'Wallapatta.Italics'
 'Wallapatta.SuperScript'
 'Wallapatta.SubScript'
 'Wallapatta.Code'
 'Wallapatta.Link'

 'Wallapatta.Block'
 'Wallapatta.Section'
 'Wallapatta.List'
 'Wallapatta.ListItem'
 'Wallapatta.Sidenote'
 'Wallapatta.Article'
 'Wallapatta.Media'

 'Wallapatta.CodeBlock'
 'Wallapatta.Special'
 'Wallapatta.Html'

 'Wallapatta.Map'

 'Wallapatta.Reader'
 'Wallapatta.Render'
 (Base, TYPES,
  Text, Bold, Italics, SuperScript, SubScript, Code, Link,
  Block, Section, List, ListItem, Sidenote, Article, Media,
  CodeBlock, Special, Html,
  Map, Reader, Render) ->

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

   BLOCK_LEVEL = 10

   class Parser extends Base
    @extend()

    @initialize (options) ->
     @map = new Map options
     @reader = new Reader options.text
     delete options.text
     @root = new Article map: @map, indentation: 0
     @node = @root
     @main = true
     @sidenotes = []
     @prevNode = null
     @blocks = []

    getRender: ->
     return new Render
      map: @map
      root: @root
      sidenotes: @sidenotes

    parse: ->
     while @reader.has()
      try
       @processLine()
      catch e
       throw new Error "Line #{@reader.n + 1}: #{e.message}"

      @reader.next()

     @map.smallElements()

     for block in @blocks
      try
       @parseText block.text, block
      catch e
       throw new Error "#{e.message}: \"#{block.text}\""

    addNode: (node) ->
     @node.add node
     if node.type is TYPES.block
      @blocks.push node
     @prevNode = @node = node

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
       @addNode new Text map: @map, text: (text.substr last, cur - last)
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
        @addNode new TOKENS[token.type] map: @map

      else
       switch token.type
        when 'linkBegin'
          add()
          @addNode new Link map: @map

        when 'linkEnd'
         if @node.type isnt TYPES.link
          throw new Error 'Unexpected link terminator'
         else
          @node.setLink @parseLink text.substr last, cur - last
          @node = @node.parent()

        when 'code'
         add()
         @addNode new Code map: @map
         last = i
         cur = i = text.indexOf TOKEN_MATCHES.code, i
         if i is -1
          cur = i = L
         add()
         @node = @node.parent()
         i += TOKEN_MATCHES.code.length


      last = i

     cur = i
     add()

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
       @addNode new CodeBlock
        map: @map
        indentation: line.indentation + 1
 #       type: line.text
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
       @node.setHeading map: @map, indentation: line.indentation + 1, text: line.text
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
        @addNode new Section map: @map, indentation: line.indentation + 1, level: BLOCK_LEVEL
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




   Mod.set 'Wallapatta.Parser', Parser

