Mod.require 'Wallapatta.Parser', (Parser) ->
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
   renderWeb render

 processAll = ->
  docs = document.getElementsByClassName 'wallapatta'
  for doc, i in docs
   process i, doc

 processAll()





document.addEventListener 'DOMContentLoaded', ->
 Mod.set 'Weya', Weya
 Mod.set 'Weya.Base', Weya.Base
 Mod.set 'HLJS', hljs
 Mod.set 'CoffeeScript', 'CoffeeScript'

 Mod.initialize()
