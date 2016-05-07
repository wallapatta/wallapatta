Mod.require 'fs',
 'path'
 'jsdom'
 'Weya'
 'Wallapatta.Parser'
 (FS, PATH, jsdom, Weya, Parser) ->
  renderPost = (options, callback) ->
   input = "#{FS.readFileSync options.file}"
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
   articles = []
   n = 0

   collect = (list) ->
    return unless list?
    for article in list
     articles.push article
     results.push {}
     collect article.content

   collect options.chapters

   for article, i in articles
    do (article, i) ->
     renderPost
      file: article.file
      id: i * 10000
      (main, sidebar, code) ->
       results[i] =
        main: main
        sidebar: sidebar
        code: code
       for k, v of article
        results[i][k] = v
       n++
       if n is articles.length
        finished()

   finished = ->
    output = template.html
     articles: results
     chapters: options.chapters

    FS.writeFileSync (PATH.join options.output, "#{options.id}.html"), output

  Mod.set 'Wallapatta.Toc', render

