Mod.require 'Wallapatta.Parser', (Parser) ->
 process = (n, doc) ->
  code = doc.getElementsByClassName 'wallapatta-code'
  if code.length isnt 1
   throw new Error 'No code element'
  code = code[0]
  main = doc.getElementsByClassName 'wallapatta-main'
  if main.length isnt 1
   throw new Error 'No main element'
  main = main[0]
  sidebar = doc.getElementsByClassName 'wallapatta-sidebar'
  if sidebar.length isnt 1
   throw new Error 'No sidebar element'
  sidebar = sidebar[0]

  parser = new Parser
   text: code.textContent
   id: n * 10000
  parser.parse()
  parser.collectElements
   main: main
   sidebar: sidebar
  window.requestAnimationFrame ->
   parser.mediaLoaded ->
    parser.setFills()
    n = 0
    int = setInterval ->
     parser.setFills()
     n++
     if n is 10
      clearInterval int
    , 1000

 docs = document.getElementsByClassName 'wallapatta'
 for doc, i in docs
  process i, doc

document.addEventListener 'DOMContentLoaded', ->
 Mod.set 'Weya', Weya
 Mod.set 'Weya.Base', Weya.Base

 Mod.initialize()
