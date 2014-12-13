Mod.require 'Weya.Base',
 'Weya'
 (Base, Weya) ->

  TYPES =
   sidenote: 'sidenote'
   codeBlock: 'codeBlock'
   special: 'special'
   html: 'html'

   section: 'section'
   heading: 'heading'

   list: 'list'
   listItem: 'listItem'

   block: 'block'
   media: 'media'

   bold: 'bold'
   italics: 'italics'
   superScript: 'superScript'
   subScript: 'subScript'
   code: 'code'
   link: 'link'
   mediaInline: 'mediaInline' #TODO

  #TODO include these in a class
  PREFIX = 'wallapatta_'

  class Map extends Base
   @initialize (options) ->
    @nodes = {}
    @id = 0
    @id = options.id if options.id
    @start = @id
    @N = 0

   smallElements: ->
    @N = @id

   add: (node) ->
    node.id = @id
    @nodes[@id] = node
    @id++


  class Node extends Base
   @extend()

   @initialize (options) ->
    @indentation = options.indentation
    @_parent = null
    @children = []
    options.map.add this
    @elems = {}

   setParent: (parent) ->  @_parent = parent
   parent: -> @_parent

   _add: (node) ->
    node.setParent this
    @children.push node
    return node

   add: (node) -> @_add node

   template: ->
    @$.elem = @div "##{PREFIX}#{@$.id}.node", null

   render: (options) ->
    Weya elem: options.elem, context: this, @template

    @renderChildren @elem, options

   renderChildren: (elem, options) ->
    for child in @children
     child.render
      elem: elem



  class Text extends Node
   @extend()

   type: TYPES.text

   @initialize (options) ->
    @text = options.text

   template: ->
    @$.elem = @span "##{PREFIX}#{@$.id}.text", @$.text



  class Bold extends Node
   @extend()
   type: TYPES.bold
   template: -> @$.elem = @strong "##{PREFIX}#{@$.id}.bold", null

  class Italics extends Node
   @extend()
   type: TYPES.italics
   template: -> @$.elem = @em "##{PREFIX}#{@$.id}.italics", null

  class SuperScript extends Node
   @extend()
   type: TYPES.superScript
   template: -> @$.elem = @sup "##{PREFIX}#{@$.id}.superScript", null

  class SubScript extends Node
   @extend()
   type: TYPES.subScript
   template: -> @$.elem = @sub "##{PREFIX}#{@$.id}.subScript", null

  class Code extends Node
   @extend()
   type: TYPES.code
   template: -> @$.elem = @code "##{PREFIX}#{@$.id}.code", null

  class Link extends Node
   @extend()

   setLink: (options) ->
    @link = options.link
    @text = options.text
    @text ?= @link

   type: TYPES.link
   template: -> @$.elem = @a "##{PREFIX}#{@$.id}.link", href: @$.link, @$.text




  class Block extends Node
   @extend()

   type: TYPES.block

   @initialize (options) ->
    @paragraph = options.paragraph
    @text = ''

   addText: (text) ->
    if @text isnt ''
     @text += ' '

    @text += text

   template: ->
    if @$.paragraph
     @$.elem = @p "##{PREFIX}#{@$.id}.paragraph", null
    else
     @$.elem = @span "##{PREFIX}#{@$.id}.block", null


  class CodeBlock extends Node
   @extend()

   type: TYPES.codeBlock

   @initialize ->
    @text = ''

   addText: (text) ->
    @text += '\n' if @text isnt ''
    @text += text

   template: ->
    @$.elem = @pre "##{PREFIX}#{@$.id}.codeBlock", @$.text


  class Special extends Node
   @extend()

   type: TYPES.special

   template: ->
    @$.elem = @div "##{PREFIX}#{@$.id}.special", null


  class Html extends Node
   @extend()

   type: TYPES.html

   @initialize ->
    @text = ''

   addText: (text) ->
    @text += '\n' if @text isnt ''
    @text += text

   render: (options) ->
    Weya elem: options.elem, context: this, ->
     @$.elem = @div "##{PREFIX}#{@$.id}.html", null

    @elem.innerHTML = @text


  class Article extends Node
   @extend()

   type: TYPES.document

   @initialize (options) ->

   template: ->
    @$.elem = @div "##{PREFIX}#{@$.id}.article", null



  class Section extends Node
   @extend()

   type: TYPES.section

   @initialize (options) ->
    @heading = new Block map: options.map, indentation: options.indentation
    @heading.setParent this
    @level = options.level

   template: ->
    @$.elem = @div "##{PREFIX}#{@$.id}.section", ->
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

    @heading.render
     elem: @elems.heading

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
     @$.elem = @ol "##{PREFIX}#{@$.id}.list", null
    else
     @$.elem = @ul "##{PREFIX}#{@$.id}.list", null



  class ListItem extends Node
   @extend()

   type: TYPES.listItem

   @initialize (options) ->
    @ordered = options.ordered

   template: ->
    @$.elem = @li "##{PREFIX}#{@$.id}.list-item", null


  class Sidenote extends Node
   @extend()

   @initialize (options) ->
    @link = options.link

   type: TYPES.sidenote

   template: ->
    @$.elem = @div "##{PREFIX}#{@$.id}.sidenote", null


  class Media extends Node
   @extend()

   @initialize (options) ->
    @src = options.media.src
    @alt = options.media.alt
    @alt ?= options.media.src

   type: TYPES.media

   add: (node) ->
    throw new Error 'Invalid indentation'

   template: ->
    @$.elem = @div "##{PREFIX}#{@$.id}.image-container", ->
     @$.elems.img = @img ".image", src: @$.src, alt: @$.alt

   render: (options) ->
    Weya elem: options.elem, context: this, @template


  Mod.set 'Wallapatta.Text', Text
  Mod.set 'Wallapatta.Bold', Bold
  Mod.set 'Wallapatta.Italics', Italics
  Mod.set 'Wallapatta.SuperScript', SuperScript
  Mod.set 'Wallapatta.SubScript', SubScript
  Mod.set 'Wallapatta.Code', Code
  Mod.set 'Wallapatta.Link', Link

  Mod.set 'Wallapatta.Block', Block
  Mod.set 'Wallapatta.Section', Section
  Mod.set 'Wallapatta.List', List
  Mod.set 'Wallapatta.ListItem', ListItem
  Mod.set 'Wallapatta.Sidenote', Sidenote
  Mod.set 'Wallapatta.Article', Article
  Mod.set 'Wallapatta.Media', Media
  Mod.set 'Wallapatta.CodeBlock', CodeBlock
  Mod.set 'Wallapatta.Special', Special
  Mod.set 'Wallapatta.Html', Html

  Mod.set 'Wallapatta.Map', Map

  Mod.set 'Wallapatta.TYPES', TYPES
