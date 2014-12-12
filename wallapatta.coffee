require './lib/mod/mod'

Mod.set 'fs', require 'fs'
Mod.set 'jsdom', require 'jsdom'
Mod.set 'Weya', require './lib/weya/weya'
Mod.set 'Weya.Base', require './lib/weya/base'
Mod.set 'yamljs', require 'yamljs'
Mod.set 'path', require 'path'

require './file'
require './paginate'

require './js/parser'
require './js/nodes'
require './js/reader'

Mod.require 'jsdom',
 'fs'
 'yamljs'
 'path'
 'Wallapatta.File'
 'Wallapatta.Paginate'
 'Weya'
 (jsdom, fs, YAML, path, FileRender, Paginate, Weya) ->

  exports.copyStatic = copyStatic = (output, callback) ->
   callback()

  renderPost = (options, opt) ->
   FileRender
    file: opt.file
    template: path.resolve __dirname, options.template
    output: path.resolve options.output, "#{opt.id}.html"
    options: opt

   if opt.content?
    for i in opt.content
     renderPost options, i


  exports.file = (options, callback) ->
   FileRender
    file: options.file
    template: path.resolve __dirname, options.template
    output: path.resolve options.output, "index.html"
    options:
     title: options.title

   copyStatic options.output, callback

  exports.book = (options, callback) ->
   data = YAML.parse "#{fs.readFileSync options.book}"
   toc = require path.resolve __dirname, options.toc

   jsdom.env '<div id="toc"></div>', (err, window) ->
    Weya.setApi document: window.document
    tocElem = window.document.getElementById 'toc'
    toc.render data, tocElem
    output = toc.html
     title: data.title
     toc: tocElem.innerHTML

    fs.writeFileSync (path.resolve options.output, "toc.html"), output

    for i in data
     renderPost options, i

   copyStatic options.output, callback


  exports.blog = (options, callback) ->
   data = YAML.parse "#{fs.readFileSync options.blog}"
   POSTS = parseInt options.posts
   inputs = []
   pages = 0
   N = Math.ceil data.length / POSTS

   paginate = ->
    Paginate
     input: inputs
     page: pages
     template: path.resolve __dirname, options.paginate
     output: options.output
     pages: N
    pages++
    inputs = []

   for i in data
    renderPost options, i
    inputs.push i
    if inputs.length is POSTS
     paginate()

   if inputs.length > 0
    paginate()

   copyStatic options.output, callback

Mod.initialize()
