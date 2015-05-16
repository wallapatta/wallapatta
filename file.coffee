Mod.require 'fs',
 'jsdom'
 'Weya'
 'Wallapatta.Parser'
 (fs, jsdom, Weya, Parser) ->
  render = (options) ->
   input = "#{fs.readFileSync options.file}"
   template = require options.template
   parser = new Parser text: input
   parser.parse()
   jsdom.env '<div id="main"></div><div id="sidebar"></div>', (err, window) ->
    Weya.setApi document: window.document
    main = window.document.getElementById 'main'
    sidebar = window.document.getElementById 'sidebar'
    render = parser.getRender()
    render.render main, sidebar
    output = template.html
     main: main.innerHTML
     sidebar: sidebar.innerHTML
     code: input
     title: options.title

    fs.writeFileSync options.output, output

  Mod.set 'Wallapatta.File', render

