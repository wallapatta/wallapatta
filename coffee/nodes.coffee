Mod.require 'Weya.Base',
 (Base) ->

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

   setParent: (parent)
    @_parent = parent

   _add: (node) ->
    node.setParent this
    @children.push node
    return node

o
  class Text extends Node
   @extend()

   type: TYPES.text

   @initialize: (options) ->
    @text = options.text



  class Block extends Node
   @extend()

   type: TYPES.block

   @initialize (options) ->
    @paragraph = options.paragraph

   add: ->
    throw new Error 'New line expected'

   addText: (text) ->
    @_add new Text text: text



  class Article extends Node
   @extend()

   type: TYPES.document

   @initialize (options) ->

   add: (node) -> @_add node



  class Section extends Node
   @extend()

   type: TYPES.section

   @initialize (options) ->
    @heading = new Block()

   add: (node) -> @_add node



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



  class ListItem extends Node
   @extend()

   type: TYPES.listItem

   @initialize (options) ->
    @ordered = options.ordered

   add: (node) -> @_add node



  class Sidenote extends Node
   @extend()

   type: TYPES.sidenote

   add: (node) -> @_add node


  Mod.set 'Docscript.Text', Text
  Mod.set 'Docscript.Block', Block
  Mod.set 'Docscript.Section', Section
  Mod.set 'Docscript.List', List
  Mod.set 'Docscript.ListItem', ListItem
  Mod.set 'Docscript.Sidenote', Sidenote

  Mod.set 'Docscript.TYPES', TYPES
