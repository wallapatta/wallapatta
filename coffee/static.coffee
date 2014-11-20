Mod.require 'Docscript.Parser', (Parser) ->
 code = document.getElementById 'code'
 main = document.getElementById 'main'
 sidebar = document.getElementById 'sidebar'
 container = document.getElementById 'docscript-container'

 parser = new Parser
  text: code.textContent
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

document.addEventListener 'DOMContentLoaded', ->
 Mod.set 'Weya', Weya
 Mod.set 'Weya.Base', Weya.Base

 Mod.initialize()
