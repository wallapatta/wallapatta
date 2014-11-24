CodeMirror.defineMode "docscript", ((cmCfg, modeCfg) ->
  operator = "tag strong"
  operatorInline = "string"
  htmlMode = CodeMirror.getMode cmCfg, name: "xml", htmlMode: true

  matchBlock = (stream, state) ->
   stack = state.stack

   match = stream.match /^<<</
   if match
    stack.push indentation: stream.indentation(), type: 'html'
    stream.skipToEnd()
    state.htmlState = CodeMirror.startState htmlMode
    return operator

   match = stream.match /^\+\+\+/
   if match
    stack.push indentation: stream.indentation(), type: 'special'
    stream.skipToEnd()
    return operator

   match = stream.match /^>>>/
   if match
    stack.push indentation: stream.indentation(), type: 'sidenote'
    stream.skipToEnd()
    return operator

   match = stream.match /^```/
   if match
    stack.push indentation: stream.indentation(), type: 'code'
    stream.skipToEnd()
    return operator

   return null

  matchStart = (stream, state) ->
   match = stream.match /^\!/
   if match
    state.media = true
    return operator
   match = stream.match /^\* /
   if match
    clearState state
    return operator
   match = stream.match /^- /
   if match
    clearState state
    return operator
   match = stream.match /^#/
   if match
    stream.eatWhile '#'
    clearState state
    state.heading = true
    return "#{operator} header"

  matchInline = (stream, state) ->
   match = stream.match /^``/
   if match
    state.code = not state.code
    return operatorInline

   if state.code
    return null

   match = stream.match /^\*\*/
   if match
    state.bold = not state.bold
    return operatorInline

   match = stream.match /^--/
   if match
    state.italics = not state.italics
    return operatorInline

   match = stream.match /^__/
   if match
    state.subscript = not state.subscript
    return operatorInline

   match = stream.match /^\^\^/
   if match
    state.superscript = not state.superscript
    return operatorInline

   match = stream.match /^<</
   if match
    state.link = true
    return operatorInline

   match = stream.match /^>>/
   if match
    state.link = false
    return operatorInline

   return null

  clearState = (state) ->
   state.bold = false
   state.italics = false
   state.subscript = false
   state.superscript = false
   state.code = false
   state.link = false


  mode =
    startState: ->
     stack: []
     htmlState: null
     start: true

     bold: false
     italics: false
     subscript: false
     superscript: false
     code: false
     link: false

     heading: false
     media: false

    blankLine: (state) ->
     clearState state

    token: (stream, state) ->
     if state.media
      stream.skipToEnd()
      state.media = false
      return "link"

     if stream.sol()
      state.start = true
      if state.heading
       state.heading = false
       clearState state

      s = stream.eatSpace()
      if stream.eol()
       clearState state

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
       special: false
       code: false

      for t in stack
       types[t.type] = true

      if not types.code and not types.html
       match = matchBlock stream, state
       return match if match?

     types =
      sidenote: false
      html: false
      special: false
      code: false

     for t in stack
      types[t.type] = true

     l = ""

     if types.html
      l = htmlMode.token stream, state.htmlState
      l = "#{l}"
     else if types.code
      stream.skipToEnd()
      l = "meta"
     else
      if state.start
       match = matchStart stream, state
       return match if match

      match = matchInline stream, state
      return match if match?

      stream.next()
      state.start = false

      if state.heading
       l += " header"
      if state.bold
       l += " strong"
      if state.italics
       l += " em"
      if state.link
       l += " link"
      if state.code
       l += " meta"

     return l

  mode
), "xml"

CodeMirror.defineMIME "text/x-docscript", "docscript"
