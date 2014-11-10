Mod.require 'Weya.Base',
 (Base) ->

  class Parser extends Base
   @extend()

   @initialize (options) ->
    @reader = new Reader options.text
    delete options.text

   parse: ->
    while @reader.has()
     @process()

   checkEmpty: (line) ->
    if line.empty
     if @node.type is BLOCK
      @node = @node.parent()
     @reader.next()

     return true
    else
     return false

   addNode: (node) ->
    @node.add node
    @node = node

   process: ->
    line = reader.get()
    @process line

    return if @checkEmpty line

    while line.indentation < @node.indentation
     @node = @node.parent()
     if not @node?
      throw new Error 'Invalid indentation'

    switch line.type
     when LIST
      if @node.type isnt LIST
       @addNode new List ordered: line.ordered, indentation: line.indentation

      @addNode new ListItem indentation: line.indentation + 1
      @addNode new Block indentation: line.indentation + 1
      @node.addText line.text

     when HEADING
      @addNode new Section indentation: line.indentation + 1
      @node.heading.addText line.text

     when SIDEBAR
      if @main
       @main = false
       n = new Sidenote indentation: line.indentation
       @mainNode = @node
       @node = n
       @sidenotes.push n
      else
       @main = true
       @node = @mainNode

     when TEXT
      if @node.type isnt BLOCK
       @addNode new Block indentation: line.indentation, paragraph: true
       @node.addText line.text

     when IMAGE
      @addNode new Media indentation: line.indentation + 1
      @node.addSrc line.text










