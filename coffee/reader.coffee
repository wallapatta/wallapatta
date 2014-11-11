Mod.require 'Weya.Base',
 'Docscript.TYPES'
 (Base, TYPES) ->

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

   parseLine: (s) ->
    line =
     indentation: 0
     empty: true

    i = 0
    while i < s.length
     break if s[i] isnt ' '
     ++i

    line.indentation = i

    return line if i is s.length

    line.empty = false

    switch s[i]
     when '#'
      line.type = TYPES.heading
      line.level = 0
      while i < s.length
       break if s[i] isnt '#'
       ++i
       ++line.level

     when '-'
      ++i
      if i < s.length && s[i] is ' '
       line.type = TYPES.list
       line.ordered = true
      else if s.substr(i, 2) is '--'
       line.type = TYPES.sidenote
       i += 2
      else
       --i #Italics

     when '*'
      ++i
      if i < s.length && s[i] is ' '
       line.type = TYPES.list
       line.ordered = false
      else
       --i #bold

     when '!'
      ++i
      line.type = TYPES.media

    line.type ?= TYPES.block

    line.text = (s.substr i).trim()

    return line



  Mod.set 'Docscript.Reader', Reader


