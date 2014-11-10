Mod.require 'Weya.Base',
 'Docscript.TYPES'
 'Docscript.Text'
 'Docscript.Block'
 'Docscript.Section'
 'Docscript.List'
 'Docscript.ListItem'
 'Docscript.Sidenote'
 'Docscript.Article'
 'Docscript.Reader'
 (Base, TYPES, Text, Block, Section, List,
  ListItem, Sidenote, Article, Reader) ->

   class Parser extends Base
    @extend()

    @initialize (options) ->
     @reader = new Reader options.text
     delete options.text
     @root = new Article indentation: 0
     @node = @root
     @main = true
     @sidenotes = []

    parse: ->
     while @reader.has()
      @process()
      @reader.next()

    checkEmpty: (line) ->
     if line.empty
      if @node.type is TYPES.block
       @node = @node.parent()
      return true
     else
      return false

    addNode: (node) ->
     @node.add node
     @node = node

    process: ->
     line = @reader.get()

     return if @checkEmpty line

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
       @addNode new Block indentation: line.indentation + 1, paragraph: false
       @node.addText line.text

      when TYPES.heading
       @addNode new Section indentation: line.indentation + 1, level: line.level
       @node.heading.addText line.text

      when TYPES.sidenote
       if @main
        @main = false
        n = new Sidenote indentation: line.indentation
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
       @addNode new Media indentation: line.indentation + 1
       @node.addSrc line.text

      else
       throw new Error 'Unknown syntax'



   Mod.set 'Docscript.Parser', Parser

