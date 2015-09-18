Mod.require 'Wallapatta.Parser', (Parser) ->
 RATIO = 0
 PAGE_HEIGHT = PAGE_WIDTH = 0
 PRINT_HEIGHT = PAGE_WIDTH = NaN

 if (window.location.href.indexOf 'print') isnt -1
  PRINT = true
  i = window.location.href.indexOf 'print'
  p = window.location.href.substr i + 'print='.length
  p = p.split 'x'
  if p.length is 2
   PRINT_WIDTH = parseInt p[0]
   PRINT_HEIGHT = parseInt p[1]
  PRINT_WIDTH = 178 if isNaN PRINT_WIDTH
  PRINT_HEIGHT = 225 if isNaN PRINT_HEIGHT
 else
  PRINT = false

 renderWeb = (render) ->
  _imagesLoaded = false
  _count = 0
  _interval = null

  _render = ->
   render.setFills()
   if _imagesLoaded
    _count++
    if _count is 10
     clearInterval _interval


  render.mediaLoaded ->
   _imagesLoaded = true
   _render()

  _interval = setInterval _render, 1000

 renderPrint = (render) ->
  render.mediaLoaded ->
   setTimeout ->
    render.setPages PAGE_HEIGHT, PAGE_WIDTH
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
   doc.style.width = "#{PRINT_WIDTH}mm"

  window.requestAnimationFrame ->
   RATIO = docs[0].offsetWidth / PRINT_WIDTH
   PAGE_WIDTH = RATIO * PRINT_WIDTH
   PAGE_HEIGHT = RATIO * PRINT_HEIGHT
   processAll()

 else
  processAll()





document.addEventListener 'DOMContentLoaded', ->
 Mod.set 'Weya', Weya
 Mod.set 'Weya.Base', Weya.Base
 Mod.set 'HLJS', hljs

 Mod.initialize()
