require './lib/mod/mod'

Mod.set 'fs', require 'fs'
Mod.set 'jsdom', require 'jsdom'
Mod.set 'Weya', './lib/weya/weya'
Mod.set 'Weya.Base', require './lib/weya/base'
Mod.set 'yamljs', require 'yamljs'

require './file'
require './paginate'

require './coffee/parser'
require './coffee/nodes'
require './coffee/reader'

Mod.require 'jsdom',
 'fs'
 'yamljs'
 'Wallapatta.File'
 'Wallapatta.Paginate'
 (jsdom, fs, YAML, FileRender, Paginate) ->

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
    file: options.input
    template: path.resolve __dirname, options.template
    output: path.resolve options.output, "index.html"
    options:
     title: options.title

   copyStatic options.output, callback

  exports.book = (options, callback) ->
   data = YAML.parse "#{fs.readFileSync options.book}"
   toc = require __dirname, options.toc

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
