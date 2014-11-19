Mod.require 'Weya.Base',
 'Docscript.TYPES'
 (Base, TYPES) ->

  BLOCK_TOKENS =
   sidenote: '>>>'
   code: '```'
   special: '+++'
   html: '<<<'
   heading: '#'
   orderedList: '- '
   unorderedList: '* '
   media: '!'

  class Reader extends Base
   @extend()

   @initialize (text) ->
    text = text.replace /\r\n?/g, "\n"
    @lines = text.split '\n'
    @n = 0
    @parse()

   has: -> @n < @lines.length

   get: -> @lines[@n]

   next: -> @n++

   parse: ->
    for s, n in @lines
     @lines[n] = @parseLine s

   getToken: (line, start) ->
    for k, v of BLOCK_TOKENS
     if v is line.substr start, v.length
      return v

    return null

   parseLine: (s) ->
    line =
     indentation: 0
     empty: true
     line: s

    i = 0
    while i < s.length
     break if s[i] isnt ' '
     ++i

    line.indentation = i

    return line if i is s.length

    line.empty = false
    token = @getToken s, i
    if token?
     i += token.length

    switch token
     when BLOCK_TOKENS.sidenote
      line.type = TYPES.sidenote

     when BLOCK_TOKENS.code
      line.type = TYPES.blockCode

     when BLOCK_TOKENS.special
      line.type = TYPES.special

     when BLOCK_TOKENS.heading
      line.type = TYPES.heading
      line.level = 1
      while i < s.length and s[i] is '#'
       ++i
       ++line.level

     when BLOCK_TOKENS.orderedList
      line.type = TYPES.list
      line.ordered = true


     when BLOCK_TOKENS.unorderedList
      line.type = TYPES.list
      line.ordered = false

     when BLOCK_TOKENS.media
      line.type = TYPES.media

     else
      line.type = TYPES.block

    line.text = (s.substr i).trim()

    return line



  Mod.set 'Docscript.Reader', Reader


