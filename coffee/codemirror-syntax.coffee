CodeMirror.defineMode "docscript", ((cmCfg, modeCfg) ->
  operator = "def strong"
  operatorInline = "keyword"
  console.log cmCfg
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

  matchInline = (stream, state) ->
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

   match = stream.match /^``/
   if match
    state.code = not state.code
    return operatorInline

   match = stream.match /^<</
   if match
    state.link = true
    return operatorInline

   match = stream.match /^>>/
   if match
    state.link = false
    return operatorInline




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

    blankLine: (state) ->
     state.bold = false
     state.italics = false
     state.subscript = false
     state.superscript = false
     state.code = false
     state.link = false

    token: (stream, state) ->
     if stream.sol()
      state.start = true
      s = stream.eatSpace()

      return "" if s

     stack = state.stack

     if state.start
      while stack.length > 0
       console.log 'indent', stream.indentation()
       if stack[stack.length - 1].indentation >= stream.indentation()
        stack.pop()
       else
        break

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
      l = "hr"
     else
      match = matchInline stream, state
      return match if match?

      stream.next()
      state.start = false

      if state.bold
       l += " strong"
      if state.italics
       l += " italics"
      if state.link
       l += " link"
      if state.code
       l += " meta"

     return l

  mode
), "xml"

CodeMirror.defineMIME "text/x-docscript", "docscript"
