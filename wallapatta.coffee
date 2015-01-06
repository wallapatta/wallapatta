require './lib/mod/mod'

Mod.set 'fs', require 'fs'
Mod.set 'jsdom', require 'jsdom'
Mod.set 'Weya', require './lib/weya/weya'
Mod.set 'Weya.Base', require './lib/weya/base'
Mod.set 'yamljs', require 'yamljs'
Mod.set 'path', require 'path'
{exec} = require 'child_process'

require './file'
require './paginate'

require './js/parser'
require './js/nodes'
require './js/reader'
require './js/render'

Mod.require 'jsdom',
 'fs'
 'yamljs'
 'path'
 'Wallapatta.File'
 'Wallapatta.Paginate'
 'Weya'
 (jsdom, fs, YAML, path, FileRender, Paginate, Weya) ->

  exports.copyStatic = copyStatic = (options, callback) ->
   if not options.static?
    callback()
    return

   commands = []
   if fs.existsSync "#{options.output}/js"
    commands.push "rm #{options.output}/js -r"
   if fs.existsSync "#{options.output}/css"
    commands.push "rm #{options.output}/css -r"
   if fs.existsSync "#{options.output}/lib"
    commands.push "rm #{options.output}/lib -r"

   commands = commands.concat [
    "mkdir #{options.output}/js"
    "mkdir #{options.output}/css"
    "mkdir #{options.output}/lib"
    "cp -r #{path.resolve __dirname, 'build/js/*'} #{options.output}/js/"
    "cp -r #{path.resolve __dirname, 'build/css/*'} #{options.output}/css/"
    "cp -r #{path.resolve __dirname, 'build/lib/*'} #{options.output}/lib/"
   ]

   exec commands.join('&&'), (e, stderr, stdout) ->
    console.error stderr.trim()
    console.log stdout.trim()
    e = (if e? then 1 else 0)
    callback e


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

   copyStatic options, callback

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

   copyStatic options, callback


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

   copyStatic options, callback

Mod.initialize()
