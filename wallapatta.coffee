require './lib/mod/mod'

Mod.set 'fs', require 'fs'
Mod.set 'jsdom', require 'jsdom'
Mod.set 'Weya', require './lib/weya/weya'
Mod.set 'Weya.Base', require './lib/weya/base'
Mod.set 'yamljs', require 'yamljs'
Mod.set 'path', require 'path'
Mod.set 'HLJS', require 'highlight.js'
Mod.set 'CoffeeScript', require 'coffee-script'
{exec} = require 'child_process'

require './file'
require './paginate'
require './toc'

require './js/parser'
require './js/nodes'
require './js/reader'
require './js/render'

GLOBAL.Weya = require './lib/weya/weya'

Mod.require 'jsdom',
 'fs'
 'yamljs'
 'path'
 'Wallapatta.File'
 'Wallapatta.Paginate'
 'Wallapatta.Toc'
 'Wallapatta.Parser'
 'Weya'
 (JSDOM, FS, YAML, PATH, FileRender, Paginate, Toc, Parser, Weya) ->

#Copy Static files
  exports.copyStatic = copyStatic = (options, callback) ->
   if not options.static?
    callback()
    return

   commands = []
   js = PATH.resolve options.output, 'js'
   css = PATH.resolve options.output, 'css'
   lib  = PATH.resolve options.output, 'lib'
   if FS.existsSync js
    commands.push "rm -r #{js}"
   if FS.existsSync css
    commands.push "rm -r #{css}"
   if FS.existsSync lib
    commands.push "rm -r #{lib}"

   commands = commands.concat [
    "mkdir #{js}"
    "mkdir #{css}"
    "mkdir #{lib}"
    "cp -r #{PATH.resolve __dirname, 'build/js/*'} #{js}"
    "cp -r #{PATH.resolve __dirname, 'build/css/*'} #{css}"
    "cp -r #{PATH.resolve __dirname, 'build/lib/*'} #{lib}"
   ]

   exec commands.join('&&'), (e, stderr, stdout) ->
    console.error stderr.trim()
    console.log stdout.trim()
    e = (if e? then 1 else 0)
    callback e


  renderChapters = (options, list) ->
   return unless list?
   for article in list
    opt =
     template: options.template
     output: PATH.resolve options.output, "#{article.id}.html"
    opt[k] = v for k, v of article
    opt.file = PATH.resolve options.cwd, article.file
    FileRender opt

    renderChapters options, article.content

#Render file
  exports.file = (options, callback) ->
   FileRender
    file: options.file
    template: PATH.resolve __dirname, options.template
    output: PATH.resolve options.output, "index.html"
    title: options.title

   copyStatic options, callback

#Render book
  exports.book = (options, callback) ->
   book = YAML.parse "#{FS.readFileSync options.book}"
   cwd = PATH.dirname options.book
   if book.articleTemplate?
    articleTemplate =
     PATH.resolve __dirname,
                  PATH.resolve cwd, book.articleTemplate
    renderChapters
     cwd: cwd
     output: options.output
     template: articleTemplate
     book.chapters

   for toc in book.toc
    tocTemplate = PATH.resolve __dirname,
                               PATH.resolve cwd, toc.template

    opt =
     chapters: book.chapters
     output: options.output
    opt[k] = v for k, v of toc
    opt.template = tocTemplate

    Toc opt

   copyStatic options, callback

#Render blog
  exports.blog = (options, callback) ->
   blog = YAML.parse "#{FS.readFileSync options.blog}"
   inputs = []
   pages = 0
   N = Math.ceil blog.posts.length / blog.postsPerPage
   cwd = PATH.dirname options.blog
   paginateTemplate =
    PATH.resolve __dirname,
                 PATH.resolve cwd, blog.paginateTemplate
   postTemplate =
    PATH.resolve __dirname,
                 PATH.resolve cwd, blog.postTemplate

   paginate = ->
    Paginate
     input: inputs
     page: pages
     template: paginateTemplate
     output: options.output
     pages: N
    pages++
    inputs = []

   for post in blog.posts
    opt =
     template: postTemplate
     output: PATH.resolve options.output, "#{post.id}.html"
    opt[k] = v for k, v of post
    opt.file = PATH.resolve cwd, post.file
    FileRender opt
    opt = {}
    opt[k] = v for k, v of post
    opt.file = PATH.resolve cwd, post.file
    inputs.push opt
    if inputs.length is blog.postsPerPage
     paginate()

   if inputs.length > 0
    paginate()

   copyStatic options, callback

#Render

  _render = exports.render = (content, callback) ->
   parser = new Parser text: content
   parser.parse()
   opt = null
   JSDOM.env '<div id="main"></div><div id="sidebar"></div>', (err, window) ->
    Weya.setApi document: window.document
    main = window.document.getElementById 'main'
    sidebar = window.document.getElementById 'sidebar'
    render = parser.getRender()
    render.render main, sidebar
    callback
     main: main.innerHTML
     sidebar: sidebar.innerHTML

#Render a list of wallapatta snippets
  exports.renderMultiple = (docs, callback) ->
   ids = (d for d of docs)
   n = 0
   results =
    main: {}
    sidebar: {}
   proc = ->
    if n is ids.length
     return callback results

    id = ids[n]
    ++n
    _render docs[id], (res) ->
     results.main[id] = res.main
     results.sidebar[id] = res.sidebar
     proc()

   proc()



Mod.initialize()
