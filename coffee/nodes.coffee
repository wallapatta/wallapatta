Mod.require 'Weya.Base',
 (Base) ->

  class Node extends Base
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

  class Text extends Node
   @initialize: (options) ->
    @text = options.text

  class Block extends Node
   @initialize: (options) ->
    options.paragraph ?= false
    @paragraph = options.paragraph

   add: ->
    throw new Error 'New line expected'

   addText: (text) ->
    @_add new Text text: text


  class Section extends Node
   @initialize (options) ->
    @heading = new Block()

   add: (node) -> @_add node



  class List extends Node
   @initialize (options) ->
    options.ordered ?= false
    @ordered = options.ordered

   add: (node) ->
    if node.type isnt TYPES.listItem
     throw new Error 'List item expected'

    if node.ordered isnt @ordered
     throw new Error 'List item type mismatch'

    @_add node



  class ListItem extends Node
