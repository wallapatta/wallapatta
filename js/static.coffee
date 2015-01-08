Mod.require 'Wallapatta.Parser', (Parser) ->
 RATIO = 0
 PAGE_HEIGHT = PAGE_WIDTH = 0

 if (window.location.href.indexOf 'print') isnt -1
  PRINT = true
 else
  PRINT = false

 renderWeb = (render) ->
  render.mediaLoaded ->
   render.setFills()
   n = 0
   int = setInterval ->
    render.setFills()
    n++
    if n is 10
     clearInterval int
   , 1000

 renderPrint = (render) ->
  render.mediaLoaded ->
   setTimeout ->
    render.setPages PAGE_HEIGHT
   , 5000

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
  render = parser.getRender()
  render.collectElements
   main: main
   sidebar: sidebar
  window.requestAnimationFrame ->
   if PRINT
    renderPrint render
   else
    renderWeb render

 processAll = ->
  docs = document.getElementsByClassName 'wallapatta'
  for doc, i in docs
   process i, doc

 if PRINT
  docs = document.getElementsByClassName 'wallapatta-container'
  for doc in docs
   doc.classList.add 'wallapatta-print'

  window.requestAnimationFrame ->
   RATIO = docs[0].offsetWidth / 170
   PAGE_WIDTH = RATIO * 170
   PAGE_HEIGHT = RATIO * 225
   processAll()

 else
  processAll()





document.addEventListener 'DOMContentLoaded', ->
 Mod.set 'Weya', Weya
 Mod.set 'Weya.Base', Weya.Base
 Mod.set 'HLJS', hljs

 Mod.initialize()
