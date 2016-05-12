cs = require 'coffee-script'
path = require 'path'
less = require 'less'
fs = require 'fs'
uglify = require "uglify-js"
LOG = (require './log').log

watch = exports.watch = (files, callback, args)->
 return unless options.watch
 for file in files
  do (file) ->
   fs.watchFile file, persistent:true, interval:1500 , (curr, prev) ->
    for f in files
     fs.unwatchFile f
    LOG "* #{file}"
    try
     callback.apply null, args
    catch err
     LOG "Error watching: #{src}"

recurse = exports.recurse = (src, dest, extension = 'coffee') ->
 exists = fs.existsSync src
 stats = exists and fs.statSync src
 isDirectory = exists and stats.isDirectory()
 files = []
 if isDirectory
  try
   fs.mkdirSync dest
  items = fs.readdirSync(src)
  for item in items
   continue if item[0] is '.'
   s = path.join src, item
   d = path.join dest, item
   files = files.concat recurse s, d
 else
  if src.length > extension.length
   if(src.substr src.length - extension.length) is extension
    files.push [src, dest]

 return files

css = exports.css = (path, src, dest, callback) ->
 try
  code = fs.readFileSync src, 'utf8'
  opt =
   paths: [path]
  if options.map
   map = "#{dest}.map"
   opt.sourceMap = on
   opt.sourceMapRootpath = "/"
   #opt.sourceMapURL = map.substr BUILD.length
   opt.filename = "#{LESS}/#{LESS_FILE}.less"
   opt.writeSourceMap = (smap) ->
    fs.writeFileSync map, smap
  if options.compress
   opt.compress = on

  less.render code, opt, (e, cssCode) ->
   if e?
    LOG " - #{src}", 'red'
    LOG "  ^ #{e.message} (col #{e.column})", 'red'
    LOG "    Near: #{e.extract}", 'red'
    callback 1
    return

   cssCode = cssCode.css

   if options.map
    url = "#{map.substr BUILD.length}"
    cssCode = "#{cssCode}\n/*# sourceMappingURL=#{url}*/\n"

   fs.writeFileSync dest, cssCode
   LOG " - #{src}" unless options.quiet
   callback 0
 catch err
  LOG " - #{src}", 'red'
  LOG "  ^ #{err.message} (col #{err.column})", 'red'
  LOG "    Near: #{err.extract}", 'red'
  callback 1

js = exports.js = (src, dest) ->
 map = "#{dest}.map"
 literate = off
 sourceMap = off
 if (src.indexOf '.litcoffee') isnt -1
  literate = on
 if options.map
  sourceMap = on
  sourceFiles = ["/#{src}"]

 try
  code = fs.readFileSync src, 'utf8'
  jsCode = cs.compile code,
   literate: literate
   sourceMap: sourceMap
   sourceFiles: sourceFiles

  if sourceMap
   url = "#{map.substr BUILD.length}"
   smap = jsCode.v3SourceMap
   jsCode = "#{jsCode.js}\n//# sourceMappingURL=#{url}\n"
   fs.writeFileSync map, smap
  fs.writeFileSync dest, jsCode
  LOG " - #{src}" unless options.quiet
  watch [src], js, [src, dest]
  return 0
 catch err
  LOG " - #{src}", 'red'
  LOG "   ^ #{err}", 'red'
  watch [src], js, [src, dest]
  return 1

compress = exports.compress = (files, dest) ->
 all = ''
 e = 0
 for src in files
  literate = off
  sourceMap = off
  if (src.indexOf '.litcoffee') isnt -1
   literate = on
  if options.map
   sourceMap = on
   sourceFiles = ["/#{src}"]
  try
   code = fs.readFileSync src, 'utf8'
   jsCode = cs.compile code,
    literate: literate
    sourceMap: sourceMap
    sourceFiles: sourceFiles
   LOG " - #{src}" unless options.quiet
   all += jsCode
  catch err
   LOG " - #{src}", 'red'
   LOG "   ^ #{err}", 'red'
   e++

 if e is 0
  try
   final = uglify.minify all, fromString: true
   fs.writeFileSync dest, final.code
  catch err
   LOG " - #{dest}", 'red'
   LOG "   ^ #{err}", 'red'
   e++


 watch files, compress, [files, dest]
 return e

exports.jsDir = (src, dest) ->
 files = recurse src, dest
 e = 0
 for file in files
  file[1] = file[1].replace '.coffee', '.js'
  file[1] = file[1].replace '.litcoffee', '.js'
  e += js file[0], file[1]

 return e


