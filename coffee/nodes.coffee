Mod.require 'Weya.Base',
 'Weya'
 (Base, Weya) ->

  NODE_ID = 0

  TYPES =
   code: 'code'
   list: 'list'
   listItem: 'listItem'
   block: 'block'
   sidenote: 'sidenote'
   section: 'section'
   heading: 'heading'
   media: 'media'


  class Node extends Base
   @extend()

   @initialize (options) ->
    @indentation = options.indentation
    @_parent = null
    @children = []
    @id = NODE_ID
    @elems = {}
    NODE_ID++

   setParent: (parent) ->  @_parent = parent
   parent: -> @_parent

   onLoaded: (callback) ->
    callback()

   _add: (node) ->
    node.setParent this
    @children.push node
    return node

   add: (node) -> @_add node

   template: ->
    @$.elem = @div ".node", null

   render: (options) ->
    Weya elem: options.elem, context: this, @template
    options.nodes[@id] = this

    @renderChildren @elem, options

   renderChildren: (elem, options) ->
    for child in @children
     child.render
      elem: elem
      nodes: options.nodes



  class Text extends Node
   @extend()

   type: TYPES.text

   @initialize (options) ->
    @text = options.text

   template: ->
    @$.elem = @span ".text", @$.text



  class Bold extends Node
   @extend()
   type: TYPES.bold
   template: -> @$.elem = @strong ".bold", null



  class Italics extends Node
   @extend()
   type: TYPES.italics
   template: -> @$.elem = @em ".italics", null



  class Block extends Node
   @extend()

   type: TYPES.block

   @initialize (options) ->
    @paragraph = options.paragraph
    @text = ''

   #add: ->
   # throw new Error 'New line expected'

   addText: (text) ->
    if @text isnt ''
     @text += ' '

    @text += text

    #if @children.length > 0
    # text = " #{text}"
    #@_add new Text text: text

   template: ->
    if @$.paragraph
     @$.elem = @p ".paragraph", null
    else
     @$.elem = @span ".block", null


  class Article extends Node
   @extend()

   type: TYPES.document

   @initialize (options) ->

   template: ->
    @$.elem = @div ".article", null



  class Section extends Node
   @extend()

   type: TYPES.section

   @initialize (options) ->
    @heading = new Block indentation: options.indentation
    @heading.setParent this
    @level = options.level

   template: ->
    @$.elem = @div ".section", ->
     h = switch @$.level
      when 1 then @h1
      when 2 then @h2
      when 3 then @h3
      when 4 then @h4
      when 5 then @h5
      when 6 then @h6

     @$.elems.heading = h.call this, ".heading", null
     @$.elems.content = @div ".content", null


   render: (options) ->
    Weya elem: options.elem, context: this, @template
    options.nodes[@id] = this

    @heading.render
     elem: @elems.heading
     nodes: options.nodes

    @renderChildren @elems.content, options



  class List extends Node
   @extend()

   type: TYPES.list

   @initialize (options) ->
    @ordered = options.ordered

   add: (node) ->
    if node.type isnt TYPES.listItem
     throw new Error 'List item expected'
    if node.ordered isnt @ordered
     throw new Error 'List item type mismatch'

    @_add node

   template: ->
    if @$.ordered
     @$.elem = @ol ".list", null
    else
     @$.elem = @ul ".list", null



  class ListItem extends Node
   @extend()

   type: TYPES.listItem

   @initialize (options) ->
    @ordered = options.ordered

   template: ->
    @$.elem = @li ".list-item", null


  class Sidenote extends Node
   @extend()

   @initialize (options) ->
    @link = options.link

   type: TYPES.sidenote

   template: ->
    @$.elem = @div ".sidenote", null


  class Media extends Node
   @extend()

   @initialize (options) ->
    @src = options.media.src
    @alt = options.media.alt
    @alt ?= options.media.src
    @loaded = false

   type: TYPES.media

   add: (node) ->
    throw new Error 'Invalid indentation'

   template: ->
    @$.elem = @div ".image-container", ->
     @$.elems.img = @img ".image", src: @$.src, alt: @$.alt

   onLoaded: (callback) ->
    @onLoadCallback = callback
    if @loaded
     @onLoadCallback()

   @listen 'load', ->
    @loaded = true
    if @onLoadCallback?
     @onLoadCallback()

   render: (options) ->
    Weya elem: options.elem, context: this, @template
    options.nodes[@id] = this
    console.log 'image', @id
    @elems.img.addEventListener 'load', @on.load

    options.nodes[@id] = this


  Mod.set 'Docscript.Text', Text
  Mod.set 'Docscript.Bold', Bold
  Mod.set 'Docscript.Italics', Italics
  Mod.set 'Docscript.Block', Block
  Mod.set 'Docscript.Section', Section
  Mod.set 'Docscript.List', List
  Mod.set 'Docscript.ListItem', ListItem
  Mod.set 'Docscript.Sidenote', Sidenote
  Mod.set 'Docscript.Article', Article
  Mod.set 'Docscript.Media', Media

  Mod.set 'Docscript.TYPES', TYPES
