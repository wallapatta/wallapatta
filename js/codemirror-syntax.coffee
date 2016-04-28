OPERATOR = "tag strong"
OPERATOR_INLINE = "tag strong"

class Mode
 constructor: (CodeMirror) ->
  @CodeMirror = CodeMirror
  @CodeMirror.defineMode "wallapatta", (@defineMode.bind this), "xml"
  @CodeMirror.defineMIME "text/x-wallapatta", "wallapatta"

 defineMode: (cmCfg, modeCfg) ->
  @htmlMode = @CodeMirror.getMode cmCfg, name: "xml", htmlMode: true
  @javascriptMode = @CodeMirror.getMode cmCfg, name: "javascript", javascriptMode: true
  @coffeescriptMode = @CodeMirror.getMode cmCfg, name: "coffeescript", coffeescriptMode: true
  @getMode()

 matchBlock: (stream, state) ->
  stack = state.stack

  match = stream.match /^<<<weya/
  if match
   stack.push indentation: stream.indentation(), type: 'coffeescript'
   stream.skipToEnd()
   state.coffeescriptState = @CodeMirror.startState @coffeescriptMode
   return OPERATOR

  match = stream.match /^<<<coffee/
  if match
   stack.push indentation: stream.indentation(), type: 'coffeescript'
   stream.skipToEnd()
   state.coffeescriptState = @CodeMirror.startState @coffeescriptMode
   return OPERATOR

  match = stream.match /^<<<js/
  if match
   stack.push indentation: stream.indentation(), type: 'javascript'
   stream.skipToEnd()
   state.javascriptState = @CodeMirror.startState @javascriptMode
   return OPERATOR

  match = stream.match /^<<</
  if match
   stack.push indentation: stream.indentation(), type: 'html'
   stream.skipToEnd()
   state.htmlState = @CodeMirror.startState @htmlMode
   return OPERATOR

  match = stream.match /^\|\|\|/
  if match
   stack.push indentation: stream.indentation(), type: 'table'
   stream.skipToEnd()
   return OPERATOR

  match = stream.match /^\+\+\+/
  if match
   stack.push indentation: stream.indentation(), type: 'special'
   stream.skipToEnd()
   return OPERATOR

  match = stream.match /^<\!>/
  if match
   stack.push indentation: stream.indentation(), type: 'full'
   stream.skipToEnd()
   return OPERATOR


  match = stream.match /^>>>/
  if match
   stack.push indentation: stream.indentation(), type: 'sidenote'
   stream.skipToEnd()
   return OPERATOR

  match = stream.match /^```/
  if match
   stack.push indentation: stream.indentation(), type: 'code'
   stream.skipToEnd()
   return OPERATOR

  match = stream.match /^<<<wallapatta/
  if match
   stack.push indentation: stream.indentation(), type: 'code'
   stream.skipToEnd()
   return OPERATOR

  return null

 matchStart: (stream, state) ->
  match = stream.match /^\!/
  if match
   state.media = true
   return OPERATOR
  match = stream.match /^\/\/\//
  if match
   state.comment = true
   return OPERATOR

  match = stream.match /^\* /
  if match
   @clearState state
   return OPERATOR
  match = stream.match /^- /
  if match
   @clearState state
   return OPERATOR
  match = stream.match /^#/
  if match
   stream.eatWhile '#'
   @clearState state
   state.heading = true
   return "#{OPERATOR} header"

 matchInline: (stream, state) ->
  match = stream.match /^``/
  if match
   state.code = not state.code
   return OPERATOR_INLINE

  if state.code
   return null

  match = stream.match /^\*\*/
  if match
   state.bold = not state.bold
   return OPERATOR_INLINE

  match = stream.match /^--/
  if match
   state.italics = not state.italics
   return OPERATOR_INLINE

  match = stream.match /^__/
  if match
   state.subscript = not state.subscript
   return OPERATOR_INLINE

  match = stream.match /^\^\^/
  if match
   state.superscript = not state.superscript
   return OPERATOR_INLINE

  match = stream.match /^<</
  if match
   state.link = true
   return OPERATOR_INLINE

  match = stream.match /^<-/
  if match
   return OPERATOR_INLINE

  match = stream.match /^->/
  if match
   return OPERATOR_INLINE

  match = stream.match /^>>/
  if match
   state.link = false
   return OPERATOR_INLINE

  match = stream.match /^\[\[/
  if match
   state.inlineMedia = true
   return OPERATOR_INLINE

  match = stream.match /^\]\]/
  if match
   state.inlineMedia = false
   return OPERATOR_INLINE

  match = stream.match /^\|/
  if match
   for t in state.stack
    if t.type is 'table'
     return OPERATOR_INLINE

  return null

 clearState: (state) ->
  state.bold = false
  state.italics = false
  state.subscript = false
  state.superscript = false
  state.code = false
  state.link = false
  state.inlineMedia = false
  state.comment = false

 startState: ->
  stack: []
  htmlState: null
  coffeescriptState: null
  javascriptState: null
  start: true

  bold: false
  italics: false
  subscript: false
  superscript: false
  code: false
  link: false
  inlineMedia: false

  heading: false
  media: false

  comment: false

 blankLine: (state) ->
  @clearState state

 token: (stream, state) ->
  if state.media
   stream.skipToEnd()
   state.media = false
   return "link"

  if stream.sol()
   state.start = true
   if state.heading
    state.heading = false
    @clearState state

   s = stream.eatSpace()
   if stream.eol()
    @clearState state

   return "" if s

  stack = state.stack

  if state.start
   while stack.length > 0
    if stack[stack.length - 1].indentation >= stream.indentation()
     stack.pop()
    else
     break

   types =
    sidenote: false
    html: false
    coffeescript: false
    javascript: false
    special: false
    full: false
    code: false
    table: false

   for t in stack
    types[t.type] = true

   if types.table
    @clearState state

   if not types.code and not types.html and not types.coffeescript and not types.javascript
    match = @matchBlock stream, state
    return match if match?

  types =
   sidenote: false
   html: false
   coffeescript: false
   javascript: false
   special: false
   full: false
   code: false
   table: false

  for t in stack
   types[t.type] = true

  l = ""

  if types.coffeescript
   l = @coffeescriptMode.token stream, state.coffeescriptState
   l = "#{l}"
  else if types.javascript
   l = @javascriptMode.token stream, state.javascriptState
   l = "#{l}"
  else if types.html
   l = @htmlMode.token stream, state.htmlState
   l = "#{l}"
  else if types.code
   stream.skipToEnd()
   l = "meta"
  else
   if state.start
    match = @matchStart stream, state
    return match if match

   state.start = false
   match = @matchInline stream, state
   return match if match?

   stream.next()

   if state.heading
    l += " header"
   if state.comment
    l += " comment"
   if state.bold
    l += " strong"
   if state.italics
    l += " em"
   if state.link
    l += " link"
   if state.inlineMedia
    l += " link"
   if state.code
    l += " meta"

  return l


 getMode: ->
  self = this

  mode =
   fold: "indent"
   startState: @startState
   blankLine: (state) -> self.blankLine state
   token: (stream, state) -> self.token stream, state

  return mode


if define? and brackets?
 define (require, exports, module) ->
  "use strict"

  LanguageManager = brackets.getModule "language/LanguageManager"
  CodeMirror = brackets.getModule "thirdparty/CodeMirror2/lib/codemirror"

  new Mode CodeMirror

  lang = LanguageManager.defineLanguage "wallapatta",
   name: "Wallapatta"
   mode: "wallapatta"
   fileExtensions: [".ds"]
   lineComment: ["\/\/"]

  lang.done ->
   console.log "[Wallapatta] Module loaded."

else if CodeMirror?
 new Mode CodeMirror
