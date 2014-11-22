CodeMirror.defineMode "docscript", ((cmCfg, modeCfg) ->
  getMode = (name) ->
    if CodeMirror.findModeByName
      found = CodeMirror.findModeByName(name)
      name = found.mime or found.mimes[0]  if found
    mode = CodeMirror.getMode(cmCfg, name)
    (if mode.name is "null" then null else mode)

  switchInline = (stream, state, f) ->
    state.f = state.inline = f
    f stream, state
  switchBlock = (stream, state, f) ->
    state.f = state.block = f
    f stream, state

  # Blocks
  blankLine = (state) ->

    # Reset linkTitle state
    state.linkTitle = false

    # Reset EM state
    state.em = false

    # Reset STRONG state
    state.strong = false

    # Reset strikethrough state
    state.strikethrough = false

    # Reset state.quote
    state.quote = 0
    if not htmlFound and state.f is htmlBlock
      state.f = inlineNormal
      state.block = blockNormal

    # Reset state.trailingSpace
    state.trailingSpace = 0
    state.trailingSpaceNewLine = false

    # Mark this line as blank
    state.thisLineHasContent = false
    null

  blockNormal = (stream, state) ->
    sol = stream.sol()
    prevLineIsList = (state.list isnt false)
    if state.list isnt false and state.indentationDiff >= 0 # Continued list
      # Only adjust indentation if *not* a code block
      state.indentation -= state.indentationDiff  if state.indentationDiff < 4
      state.list = null
    else if state.list isnt false and state.indentation > 0
      state.list = null
      state.listDepth = Math.floor(state.indentation / 4)
    else if state.list isnt false # No longer a list
      state.list = false
      state.listDepth = 0
    match = null
    if state.indentationDiff >= 4
      state.indentation -= 4
      stream.skipToEnd()
      return code
    else if stream.eatSpace()
      return null
    else
      match = stream.match(atxHeaderRE)
      if match
        state.header = (if match[0].length <= 6 then match[0].length else 6)
        state.formatting = "header"  if modeCfg.highlightFormatting
        state.f = state.inline
        return getType(state)
      else if state.prevLineHasContent and (match = stream.match(setextHeaderRE))
        state.header = (if match[0].charAt(0) is "=" then 1 else 2)
        state.formatting = "header"  if modeCfg.highlightFormatting
        state.f = state.inline
        return getType(state)
      else if stream.eat(">")
        state.indentation++
        state.quote = (if sol then 1 else state.quote + 1)
        state.formatting = "quote"  if modeCfg.highlightFormatting
        stream.eatSpace()
        return getType(state)
      else if stream.peek() is "["
        return switchInline(stream, state, footnoteLink)
      else if stream.match(hrRE, true)
        return hr
      else if (not state.prevLineHasContent or prevLineIsList) and (stream.match(ulRE, false) or stream.match(olRE, false))
        listType = null
        if stream.match(ulRE, true)
          listType = "ul"
        else
          stream.match olRE, true
          listType = "ol"
        state.indentation += 4
        state.list = true
        state.listDepth++
        state.taskList = true  if modeCfg.taskLists and stream.match(taskListRE, false)
        state.f = state.inline
        state.formatting = [ "list", "list-" + listType ]  if modeCfg.highlightFormatting
        return getType(state)
      else if modeCfg.fencedCodeBlocks and stream.match(/^```[ \t]*([\w+#]*)/, true)

        # try switching mode
        state.localMode = getMode(RegExp.$1)
        state.localState = state.localMode.startState()  if state.localMode
        state.f = state.block = local
        state.formatting = "code-block"  if modeCfg.highlightFormatting
        state.code = true
        return getType(state)
    switchInline stream, state, state.inline
  htmlBlock = (stream, state) ->
    style = htmlMode.token(stream, state.htmlState)
    if (htmlFound and state.htmlState.tagStart is null and not state.htmlState.context) or (state.md_inside and stream.current().indexOf(">") > -1)
      state.f = inlineNormal
      state.block = blockNormal
      state.htmlState = null
    style
  local = (stream, state) ->
    if stream.sol() and stream.match("```", false)
      state.localMode = state.localState = null
      state.f = state.block = leavingLocal
      null
    else if state.localMode
      state.localMode.token stream, state.localState
    else
      stream.skipToEnd()
      code
  leavingLocal = (stream, state) ->
    stream.match "```"
    state.block = blockNormal
    state.f = inlineNormal
    state.formatting = "code-block"  if modeCfg.highlightFormatting
    state.code = true
    returnType = getType(state)
    state.code = false
    returnType

  # Inline
  getType = (state) ->
    styles = []
    if state.formatting
      styles.push formatting
      state.formatting = [ state.formatting ]  if typeof state.formatting is "string"
      i = 0

      while i < state.formatting.length
        styles.push formatting + "-" + state.formatting[i]
        styles.push formatting + "-" + state.formatting[i] + "-" + state.header  if state.formatting[i] is "header"

        # Add `formatting-quote` and `formatting-quote-#` for blockquotes
        # Add `error` instead if the maximum blockquote nesting depth is passed
        if state.formatting[i] is "quote"
          if not modeCfg.maxBlockquoteDepth or modeCfg.maxBlockquoteDepth >= state.quote
            styles.push formatting + "-" + state.formatting[i] + "-" + state.quote
          else
            styles.push "error"
        i++
    if state.taskOpen
      styles.push "meta"
      return (if styles.length then styles.join(" ") else null)
    if state.taskClosed
      styles.push "property"
      return (if styles.length then styles.join(" ") else null)
    if state.linkHref
      styles.push linkhref
      return (if styles.length then styles.join(" ") else null)
    styles.push strong  if state.strong
    styles.push em  if state.em
    styles.push strikethrough  if state.strikethrough
    styles.push linktext  if state.linkText
    styles.push code  if state.code
    if state.header
      styles.push header
      styles.push header + "-" + state.header
    if state.quote
      styles.push quote

      # Add `quote-#` where the maximum for `#` is modeCfg.maxBlockquoteDepth
      if not modeCfg.maxBlockquoteDepth or modeCfg.maxBlockquoteDepth >= state.quote
        styles.push quote + "-" + state.quote
      else
        styles.push quote + "-" + modeCfg.maxBlockquoteDepth
    if state.list isnt false
      listMod = (state.listDepth - 1) % 3
      unless listMod
        styles.push list1
      else if listMod is 1
        styles.push list2
      else
        styles.push list3
    if state.trailingSpaceNewLine
      styles.push "trailing-space-new-line"
    else styles.push "trailing-space-" + ((if state.trailingSpace % 2 then "a" else "b"))  if state.trailingSpace
    (if styles.length then styles.join(" ") else null)
  handleText = (stream, state) ->
    return getType(state)  if stream.match(textRE, true)
    `undefined`
  inlineNormal = (stream, state) ->
    t = undefined
    type = undefined
    style = state.text(stream, state)
    return style  if typeof style isnt "undefined"
    if state.list # List marker (*, +, -, 1., etc)
      state.list = null
      return getType(state)
    if state.taskList
      taskOpen = stream.match(taskListRE, true)[1] isnt "x"
      if taskOpen
        state.taskOpen = true
      else
        state.taskClosed = true
      state.formatting = "task"  if modeCfg.highlightFormatting
      state.taskList = false
      return getType(state)
    state.taskOpen = false
    state.taskClosed = false
    if state.header and stream.match(/^#+$/, true)
      state.formatting = "header"  if modeCfg.highlightFormatting
      return getType(state)

    # Get sol() value now, before character is consumed
    sol = stream.sol()
    ch = stream.next()
    if ch is "\\"
      stream.next()
      if modeCfg.highlightFormatting
        type = getType(state)
        return (if type then type + " formatting-escape" else "formatting-escape")

    # Matches link titles present on next line
    if state.linkTitle
      state.linkTitle = false
      matchCh = ch
      matchCh = ")"  if ch is "("
      matchCh = (matchCh + "").replace(/([.?*+^$[\]\\(){}|-])/g, "\\$1")
      regex = "^\\s*(?:[^" + matchCh + "\\\\]+|\\\\\\\\|\\\\.)" + matchCh
      return linkhref  if stream.match(new RegExp(regex), true)

    # If this block is changed, it may need to be updated in GFM mode
    if ch is "`"
      previousFormatting = state.formatting
      state.formatting = "code"  if modeCfg.highlightFormatting
      t = getType(state)
      before = stream.pos
      stream.eatWhile "`"
      difference = 1 + stream.pos - before
      unless state.code
        codeDepth = difference
        state.code = true
        return getType(state)
      else
        if difference is codeDepth # Must be exact
          state.code = false
          return t
        state.formatting = previousFormatting
        return getType(state)
    else return getType(state)  if state.code
    if ch is "!" and stream.match(/\[[^\]]*\] ?(?:\(|\[)/, false)
      stream.match /\[[^\]]*\]/
      state.inline = state.f = linkHref
      return image
    if ch is "[" and stream.match(/.*\](\(| ?\[)/, false)
      state.linkText = true
      state.formatting = "link"  if modeCfg.highlightFormatting
      return getType(state)
    if ch is "]" and state.linkText
      state.formatting = "link"  if modeCfg.highlightFormatting
      type = getType(state)
      state.linkText = false
      state.inline = state.f = linkHref
      return type
    if ch is "<" and stream.match(/^(https?|ftps?):\/\/(?:[^\\>]|\\.)+>/, false)
      state.f = state.inline = linkInline
      state.formatting = "link"  if modeCfg.highlightFormatting
      type = getType(state)
      if type
        type += " "
      else
        type = ""
      return type + linkinline
    if ch is "<" and stream.match(/^[^> \\]+@(?:[^\\>]|\\.)+>/, false)
      state.f = state.inline = linkInline
      state.formatting = "link"  if modeCfg.highlightFormatting
      type = getType(state)
      if type
        type += " "
      else
        type = ""
      return type + linkemail
    if ch is "<" and stream.match(/^\w/, false)
      unless stream.string.indexOf(">") is -1
        atts = stream.string.substring(1, stream.string.indexOf(">"))
        state.md_inside = true  if /markdown\s*=\s*('|"){0,1}1('|"){0,1}/.test(atts)
      stream.backUp 1
      state.htmlState = CodeMirror.startState(htmlMode)
      return switchBlock(stream, state, htmlBlock)
    if ch is "<" and stream.match(/^\/\w*?>/)
      state.md_inside = false
      return "tag"
    ignoreUnderscore = false
    unless modeCfg.underscoresBreakWords
      if ch is "_" and stream.peek() isnt "_" and stream.match(/(\w)/, false)
        prevPos = stream.pos - 2
        if prevPos >= 0
          prevCh = stream.string.charAt(prevPos)
          ignoreUnderscore = true  if prevCh isnt "_" and prevCh.match(/(\w)/, false)
    if ch is "*" or (ch is "_" and not ignoreUnderscore)
      if sol and stream.peek() is " "


      # Do nothing, surrounded by newline and space
      else if state.strong is ch and stream.eat(ch) # Remove STRONG
        state.formatting = "strong"  if modeCfg.highlightFormatting
        t = getType(state)
        state.strong = false
        return t
      else if not state.strong and stream.eat(ch) # Add STRONG
        state.strong = ch
        state.formatting = "strong"  if modeCfg.highlightFormatting
        return getType(state)
      else if state.em is ch # Remove EM
        state.formatting = "em"  if modeCfg.highlightFormatting
        t = getType(state)
        state.em = false
        return t
      else unless state.em # Add EM
        state.em = ch
        state.formatting = "em"  if modeCfg.highlightFormatting
        return getType(state)
    else if ch is " "
      if stream.eat("*") or stream.eat("_") # Probably surrounded by spaces
        if stream.peek() is " " # Surrounded by spaces, ignore
          return getType(state)
        else # Not surrounded by spaces, back up pointer
          stream.backUp 1
    if modeCfg.strikethrough
      if ch is "~" and stream.eatWhile(ch)
        if state.strikethrough # Remove strikethrough
          state.formatting = "strikethrough"  if modeCfg.highlightFormatting
          t = getType(state)
          state.strikethrough = false
          return t
        else if stream.match(/^[^\s]/, false) # Add strikethrough
          state.strikethrough = true
          state.formatting = "strikethrough"  if modeCfg.highlightFormatting
          return getType(state)
      else if ch is " "
        if stream.match(/^~~/, true) # Probably surrounded by space
          if stream.peek() is " " # Surrounded by spaces, ignore
            return getType(state)
          else # Not surrounded by spaces, back up pointer
            stream.backUp 2
    if ch is " "
      if stream.match(RegExp(" +$"), false)
        state.trailingSpace++
      else state.trailingSpaceNewLine = true  if state.trailingSpace
    getType state
  linkInline = (stream, state) ->
    ch = stream.next()
    if ch is ">"
      state.f = state.inline = inlineNormal
      state.formatting = "link"  if modeCfg.highlightFormatting
      type = getType(state)
      if type
        type += " "
      else
        type = ""
      return type + linkinline
    stream.match /^[^>]+/, true
    linkinline
  linkHref = (stream, state) ->

    # Check if space, and return NULL if so (to avoid marking the space)
    return null  if stream.eatSpace()
    ch = stream.next()
    if ch is "(" or ch is "["
      state.f = state.inline = getLinkHrefInside((if ch is "(" then ")" else "]"))
      state.formatting = "link-string"  if modeCfg.highlightFormatting
      state.linkHref = true
      return getType(state)
    "error"
  getLinkHrefInside = (endChar) ->
    (stream, state) ->
      ch = stream.next()
      if ch is endChar
        state.f = state.inline = inlineNormal
        state.formatting = "link-string"  if modeCfg.highlightFormatting
        returnState = getType(state)
        state.linkHref = false
        return returnState
      stream.backUp 1  if stream.match(inlineRE(endChar), true)
      state.linkHref = true
      getType state
  footnoteLink = (stream, state) ->
    if stream.match(/^[^\]]*\]:/, false)
      state.f = footnoteLinkInside
      stream.next() # Consume [
      state.formatting = "link"  if modeCfg.highlightFormatting
      state.linkText = true
      return getType(state)
    switchInline stream, state, inlineNormal
  footnoteLinkInside = (stream, state) ->
    if stream.match(/^\]:/, true)
      state.f = state.inline = footnoteUrl
      state.formatting = "link"  if modeCfg.highlightFormatting
      returnType = getType(state)
      state.linkText = false
      return returnType
    stream.match /^[^\]]+/, true
    linktext
  footnoteUrl = (stream, state) ->

    # Check if space, and return NULL if so (to avoid marking the space)
    return null  if stream.eatSpace()

    # Match URL
    stream.match /^[^\s]+/, true

    # Check for link title
    if stream.peek() is `undefined` # End of line, set flag to check next line
      state.linkTitle = true
    else # More content on line, check if link title
      stream.match /^(?:\s+(?:"(?:[^"\\]|\\\\|\\.)+"|'(?:[^'\\]|\\\\|\\.)+'|\((?:[^)\\]|\\\\|\\.)+\)))?/, true
    state.f = state.inline = inlineNormal
    linkhref
  inlineRE = (endChar) ->
    unless savedInlineRE[endChar]

      # Escape endChar for RegExp (taken from http://stackoverflow.com/a/494122/526741)
      endChar = (endChar + "").replace(/([.?*+^$[\]\\(){}|-])/g, "\\$1")

      # Match any non-endChar, escaped character, as well as the closing
      # endChar.
      savedInlineRE[endChar] = new RegExp("^(?:[^\\\\]|\\\\.)*?(" + endChar + ")")
    savedInlineRE[endChar]
  htmlFound = CodeMirror.modes.hasOwnProperty("xml")
  htmlMode = "text/plain"
  if htmlFound
   htmlMode = name: "xml", htmlMode: true
  htmlMode = CodeMirror.getMode cmCfg, htmlMode
  modeCfg.highlightFormatting = false  if modeCfg.highlightFormatting is `undefined`
  modeCfg.maxBlockquoteDepth = 0  if modeCfg.maxBlockquoteDepth is `undefined`
  modeCfg.underscoresBreakWords = true  if modeCfg.underscoresBreakWords is `undefined`
  modeCfg.fencedCodeBlocks = false  if modeCfg.fencedCodeBlocks is `undefined`
  modeCfg.taskLists = false  if modeCfg.taskLists is `undefined`
  modeCfg.strikethrough = false  if modeCfg.strikethrough is `undefined`
  codeDepth = 0
  header = "header"
  code = "comment"
  quote = "quote"
  list1 = "variable-2"
  list2 = "variable-3"
  list3 = "keyword"
  hr = "hr"
  image = "tag"
  formatting = "formatting"
  linkinline = "link"
  linkemail = "link"
  linktext = "link"
  linkhref = "string"
  em = "em"
  strong = "strong"
  strikethrough = "strikethrough"
  hrRE = /^([*\-=_])(?:\s*\1){2,}\s*$/
  ulRE = /^[*\-+]\s+/
  olRE = /^[0-9]+\.\s+/
  taskListRE = /^\[(x| )\](?=\s)/
  atxHeaderRE = /^#+/
  setextHeaderRE = /^(?:\={1,}|-{1,})$/
  textRE = /^[^#!\[\]*_\\<>` "'(~]+/
  savedInlineRE = []


  operator = "keyword"
  console.log cmCfg
  htmlMode = CodeMirror.getMode cmCfg, name: "xml", htmlMode: true

  mode =
    startState: ->
     stack: []
     isHtml: false
     htmlState: null


    token: (stream, state) ->
     if stream.sol()
      return "" if stream.eatSpace()

     if state.isHtml
      console.log 'html'
      match = stream.match /^<<</
      if match
       state.isHtml = false
       return operator
      else
       l = htmlMode.token stream, state.htmlState
       console.log l
       return l
     else
      console.log 'not html'
      match = stream.match /^<<</
      if match
       state.isHtml = true
       stream.skipToEnd()
       state.htmlState = CodeMirror.startState htmlMode
       console.log state.htmlState
       return operator

      else
       stream.skipToEnd()
       return ""

  mode
), "xml"

CodeMirror.defineMIME "text/x-docscript", "docscript"
