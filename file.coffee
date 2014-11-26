Mod.require 'fs',
 'jsdom'
 'Weya'
 'Docscript.Parser'
 (fs, jsdom, Weya, Parser) ->
  render = (options) ->
   input = "#{fs.readFileSync options.input}"
   page = require options.page
   parser = new Parser text: input
   parser.parse()
   jsdom.env '<div id="main"></div><div id="sidebar"></div>', (err, window) ->
    Weya.setApi document: window.document
    main = window.document.getElementById 'main'
    sidebar = window.document.getElementById 'sidebar'
    parser.render main, sidebar
    output = page.html
     main: main.innerHTML
     sidebar: sidebar.innerHTML
     code: input

    fs.writeFileSync options.output, output

  Mod.set 'Docscript.File', render

