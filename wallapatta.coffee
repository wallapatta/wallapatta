require './lib/mod/mod'

Mod.set 'fs', require 'fs'
Mod.set 'jsdom', require 'jsdom'
Mod.set 'Weya', require './lib/weya/weya'
Mod.set 'Weya.Base', require './lib/weya/base'
Mod.set 'yamljs', require 'yamljs'
Mod.set 'path', require 'path'
Mod.set 'HLJS', require 'highlight.js'
{exec} = require 'child_process'

require './file'
require './paginate'
require './toc'

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
 'Wallapatta.Toc'
 'Weya'
 (jsdom, fs, YAML, path, FileRender, Paginate, Toc, Weya) ->

  exports.copyStatic = copyStatic = (options, callback) ->
   if not options.static?
    callback()
    return

   commands = []
   js = path.resolve options.output, 'js'
   css = path.resolve options.output, 'css'
   lib  = path.resolve options.output, 'lib'
   if fs.existsSync js
    commands.push "rm -r #{js}"
   if fs.existsSync css
    commands.push "rm -r #{css}"
   if fs.existsSync lib
    commands.push "rm -r #{lib}"

   commands = commands.concat [
    "mkdir #{js}"
    "mkdir #{css}"
    "mkdir #{lib}"
    "cp -r #{path.resolve __dirname, 'build/js/*'} #{js}"
    "cp -r #{path.resolve __dirname, 'build/css/*'} #{css}"
    "cp -r #{path.resolve __dirname, 'build/lib/*'} #{lib}"
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
     output: path.resolve options.output, "#{article.id}.html"
    opt[k] = v for k, v of article
    opt.file = path.resolve options.cwd, article.file
    FileRender opt

    renderChapters options, article.content

  exports.file = (options, callback) ->
   FileRender
    file: options.file
    template: path.resolve __dirname, options.template
    output: path.resolve options.output, "index.html"
    title: options.title

   copyStatic options, callback

  exports.book = (options, callback) ->
   book = YAML.parse "#{fs.readFileSync options.book}"
   cwd = path.dirname options.book
   articleTemplate =
    path.resolve __dirname,
                 path.resolve cwd, book.articleTemplate

   renderChapters
    cwd: cwd
    output: options.output
    template: articleTemplate
    book.chapters

   for toc in book.toc
    tocTemplate = path.resolve __dirname,
                               path.resolve cwd, toc.template

    opt =
     chapters: book.chapters
     output: options.output
    opt[k] = v for k, v of toc
    opt.template = tocTemplate

    Toc opt

   copyStatic options, callback


  exports.blog = (options, callback) ->
   blog = YAML.parse "#{fs.readFileSync options.blog}"
   inputs = []
   pages = 0
   N = Math.ceil blog.posts.length / blog.postsPerPage
   cwd = path.dirname options.blog
   paginateTemplate =
    path.resolve __dirname,
                 path.resolve cwd, blog.paginateTemplate
   postTemplate =
    path.resolve __dirname,
                 path.resolve cwd, blog.postTemplate

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
     output: path.resolve options.output, "#{post.id}.html"
    opt[k] = v for k, v of post
    opt.file = path.resolve cwd, post.file
    FileRender opt
    opt = {}
    opt[k] = v for k, v of post
    opt.file = path.resolve cwd, post.file
    inputs.push opt
    if inputs.length is blog.postsPerPage
     paginate()

   if inputs.length > 0
    paginate()

   copyStatic options, callback

Mod.initialize()
