Mod.require 'fs',
 'jsdom'
 'Weya'
 'Wallapatta.Parser'
 (fs, jsdom, Weya, Parser) ->
  renderPost = (options, callback) ->
   input = "#{fs.readFileSync options.file}"
   parser = new Parser text: input, id: options.id
   parser.parse()
   jsdom.env '<div id="main"></div><div id="sidebar"></div>', (err, window) ->
    Weya.setApi document: window.document
    main = window.document.getElementById 'main'
    sidebar = window.document.getElementById 'sidebar'
    render = parser.getRender()
    render.render main, sidebar
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
       for k, v of input
        results[i][k] = v
       n++
       if n is options.input.length
        finished()

   finished = ->
    output = template.html
     posts: results
     pages: options.pages
     page: options.page

    fs.writeFileSync "./#{options.output}/page#{options.page + 1}.html", output
    if options.page is 0
     fs.writeFileSync "./#{options.output}/index.html", output

  Mod.set 'Wallapatta.Paginate', render

