Mod.require 'Weya.Base',
 'Weya'
 'HLJS'
 'CoffeeScript'
 (Base, Weya, HLJS, CoffeeScript) ->

  decodeURL = (url) ->
   if window?.wallapattaDecodeURL?
    return window.wallapattaDecodeURL url
   else
    return url


  TYPES =
   article: 'article'

   sidenote: 'sidenote'
   codeBlock: 'codeBlock'
   formattedCode: 'formattedCode'
   special: 'special'
   full: 'full'
   html: 'html'
   table: 'table'

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
   htmlInline: 'htmlInline'
   mediaInline: 'mediaInline' #TODO

   comment: '///'

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

   isFirstChild: (node) ->
    return false if @children.length is 0
    if node.id is @children[0].id
     return true
    else
     return false

   getChildPosition: (node) ->
    return 1 if @children.length is 0
    n = @children.length
    for child, i in @children
     if child.id is node.id
      n = i

    return n / @children.length

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


  class MediaInline extends Node
   @extend()

   type: TYPES.mediaInline

   setMedia: (options) ->
    @src = options.src
    @alt = options.alt
    @alt ?= options.src

   template: ->
    @$.elem = @img "##{PREFIX}#{@$.id}.image-inline",
     src: (decodeURL @$.src)
     alt: @$.alt

   render: (options) ->
    Weya elem: options.elem, context: this, @template


  class Block extends Node
   @extend()

   type: TYPES.block

   @initialize (options) ->
    @paragraph = options.paragraph
    @text = ''

   addText: (text) ->
    @text += ' ' if @text isnt ''
    @text += text

   template: ->
    if @$.paragraph
     @$.elem = @p "##{PREFIX}#{@$.id}.paragraph", null
    else
     @$.elem = @span "##{PREFIX}#{@$.id}.block", null

  class FormattedCode extends Node
   @extend()

   type: TYPES.formattedCode

   @initialize (options) ->
    @text = ''

   addText: (text) ->
    @text += '\n' if @text isnt ''
    @text += text

   template: ->
    @$.elem = @pre "##{PREFIX}#{@$.id}.formattedCode", null

  class CodeBlock extends Node
   @extend()

   type: TYPES.codeBlock

   @initialize (options) ->
    @text = ''
    @lang = options.lang.trim()
    @cssClass = ".nohighlight"
    @cssClass = ".#{@lang}" if @lang isnt ''

   addText: (text) ->
    @text += '\n' if @text isnt ''
    @text += text

   render: (options) ->
    code = @text.trimRight()
    html = false

    if @lang isnt '' and HLJS? and (HLJS.getLanguage @lang)?
     code = HLJS.highlight @lang, code, true
     code = code.value
     html = true

    codeElem = null

    Weya elem: options.elem, context: this, ->
     @$.elem = @pre "##{PREFIX}#{@$.id}.codeBlock", ->
      codeElem = @code @$.cssClass, ""

    if html
     codeElem.innerHTML = code
    else
     codeElem.textContent = code

  class Table extends Node
   @extend()

   type: TYPES.table

   @initialize (options) ->
    @table = []
    @header = 0

   addText: (text, options) ->
    if (text.trim().substr 0, 3) is '==='
     @header = @table.length
     return []

    text = text.split '|'
    row = []
    nodes = []
    for cell in text
     if cell is ''
      if row.length > 0
       row[row.length - 1].span++
      continue

     if (cell.substr 0, 2) is '!!'
      node = new Media
       map: options.map
       indentation: @indentation
       media: {src: cell.substr 2}
      node.setParent this
     else
      node = new Block map: options.map, indentation: @indentation
      node.setParent this
      node.addText cell.trim()

     row.push
      span: 1
      node: node

     nodes.push node

    @table.push row

    return nodes

   render: (options) ->
    codeElem = null
    elems = []

    Weya elem: options.elem, context: this, ->
     @$.elem = @table "##{PREFIX}#{@$.id}.table", ->
      @thead ->
       for i in [0...@$.header]
        row = @$.table[i]
        cells = []
        @tr ->
         for cell in row
          cells.push @th colspan: cell.span
        elems.push cells
      @tbody ->
       for i in [@$.header...@$.table.length]
        row = @$.table[i]
        cells = []
        @tr ->
         for cell in row
          cells.push @td colspan: cell.span
        elems.push cells

    for row, i in elems
     for cell, j in row
      @table[i][j].node.render elem: cell




  class Special extends Node
   @extend()

   type: TYPES.special

   template: ->
    @$.elem = @div "##{PREFIX}#{@$.id}.special", null


  class Full extends Node
   @extend()

   type: TYPES.full

   template: ->
    @$.elem = @div "##{PREFIX}#{@$.id}.full", null


  class Html extends Node
   @extend()

   type: TYPES.html

   @initialize (options) ->
    @text = ''
    @lang = options.lang.trim()

   addText: (text) ->
    @text += '\n' if @text isnt ''
    @text += text

   render: (options) ->
    if @lang is 'js'
     try
      f = new Function "return (#{@text})"
      s = f()
     catch e
      s = e.message
    else if @lang is 'coffee'
     try
      c = CoffeeScript.compile "return (#{@text})"
      f = new Function "return #{c}"
      s = f()
     catch e
      s = e.message
    else if @lang is 'weya'
     try
      w = "Weya.markup {}, ->\n"
      lines = @text.split '\n'
      for l in lines
       w += " #{l}\n"
      c = CoffeeScript.compile "return (#{w})"
      f = new Function "return #{c}"
      s = f()
     catch e
      s = e.message
    else
     s = @text

    Weya elem: options.elem, context: this, ->
     @$.elem = @div "##{PREFIX}#{@$.id}.html", null

    @elem.innerHTML = s


  class HtmlInline extends Node
   @extend()

   type: TYPES.htmlInline

   @initialize ->
    @text = ''

   addText: (text) ->
    @text += '\n' if @text isnt ''
    @text += text

   render: (options) ->
    Weya elem: options.elem, context: this, ->
     @$.elem = @span "##{PREFIX}#{@$.id}.html", null

    @elem.innerHTML = @text



  class Article extends Node
   @extend()

   type: TYPES.article

   @initialize (options) ->

   template: ->
    @$.elem = @div "##{PREFIX}#{@$.id}.article", null



  class Section extends Node
   @extend()

   type: TYPES.section

   @initialize (options) ->
    @level = options.level

   setHeading: (options) ->
    @heading = new Block map: options.map, indentation: options.indentation
    @heading.setParent this
    @heading.addText options.text

   isFirstChild: (node) ->
    if (Node::isFirstChild.call this, node) is true
     return true
    else if @heading? and node.id is @heading.id
     return true
    else
     return false

   getChildPosition: (node) ->
    if @heading? and node.id is @heading.id
     return 0
    else
     return Node::getChildPosition.call this, node

   template: ->
    @$.elem = @div "##{PREFIX}#{@$.id}.section", ->
     h = switch @$.level
      when 1 then @h1
      when 2 then @h2
      when 3 then @h3
      when 4 then @h4
      when 5 then @h5
      when 6 then @h6
      else null

     if h?
      @$.elems.heading = h.call this, ".heading", null
     @$.elems.content = @div ".content", null


   render: (options) ->
    Weya elem: options.elem, context: this, @template

    if @elems.heading?
     @heading.render elem: @elems.heading

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
    @width = options.media.width

   type: TYPES.media

   add: (node) ->
    throw new Error 'Invalid indentation'

   template: ->
    @$.elem = @div "##{PREFIX}#{@$.id}.image-container", ->
     @$.elems.img = @img ".image",
      src: (decodeURL @$.src)
      alt: @$.alt
     if @$.width?
      @$.elems.img.style.maxWidth = "#{@$.width}%"

   render: (options) ->
    Weya elem: options.elem, context: this, @template


  Mod.set 'Wallapatta.Text', Text
  Mod.set 'Wallapatta.Bold', Bold
  Mod.set 'Wallapatta.Italics', Italics
  Mod.set 'Wallapatta.SuperScript', SuperScript
  Mod.set 'Wallapatta.SubScript', SubScript
  Mod.set 'Wallapatta.Code', Code
  Mod.set 'Wallapatta.Link', Link
  Mod.set 'Wallapatta.MediaInline', MediaInline

  Mod.set 'Wallapatta.Block', Block
  Mod.set 'Wallapatta.Section', Section
  Mod.set 'Wallapatta.List', List
  Mod.set 'Wallapatta.ListItem', ListItem
  Mod.set 'Wallapatta.Sidenote', Sidenote
  Mod.set 'Wallapatta.Article', Article
  Mod.set 'Wallapatta.Media', Media
  Mod.set 'Wallapatta.CodeBlock', CodeBlock
  Mod.set 'Wallapatta.FormattedCode', FormattedCode
  Mod.set 'Wallapatta.Table', Table
  Mod.set 'Wallapatta.Special', Special
  Mod.set 'Wallapatta.Html', Html
  Mod.set 'Wallapatta.Full', Full
  Mod.set 'Wallapatta.HtmlInline', HtmlInline

  Mod.set 'Wallapatta.Map', Map

  Mod.set 'Wallapatta.TYPES', TYPES
