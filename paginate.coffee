Mod.require 'fs',
 'jsdom'
 'Weya'
 'Docscript.Parser'
 (fs, jsdom, Weya, Parser) ->
  renderPost = (options, callback) ->
   input = "#{fs.readFileSync options.file}"
   parser = new Parser text: input, id: options.id
   parser.parse()
   jsdom.env '<div id="main"></div><div id="sidebar"></div>', (err, window) ->
    Weya.setApi document: window.document
    main = window.document.getElementById 'main'
    sidebar = window.document.getElementById 'sidebar'
    parser.render main, sidebar
    callback main.innerHTML, sidebar.innerHTML, input

  render = (options) ->
   template = require options.template
   results = []
   n = 0
   for i in options.input
    results.push {}

   for input, i in options.input
    do (input, i) ->
     renderPost
      file: input.file
      id: i * 10000
      (main, sidebar, code) ->
       results[i] =
        main: main
        sidebar: sidebar
        code: code
       n++
       if n is options.input.length
        finished()

   finished = ->
    output = template.html
     posts: results

    fs.writeFileSync "./#{options.output}/page#{options.page + 1}.html", output

  Mod.set 'Docscript.Paginate', render

