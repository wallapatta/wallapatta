Mod.require 'Weya.Base',
 (Base) ->

  class Node extends Base
   @initialize: (options) ->
    @indentation = options.indentation
    @_parent = null
    @children = []

   setParent: (parent)
    @_parent = parent

   _add: (node) ->
    node.setParent this
    @children.push node
    return node



  class Block extends Node
   add: ->
    throw new Error 'New line expected'
