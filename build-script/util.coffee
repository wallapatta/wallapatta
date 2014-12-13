cs = require 'coffee-script'
path = require 'path'
less = require 'less'
fs = require 'fs'
uglify = require "uglify-js"

COLORS =
 reset: ''
 bold: ';1'
 red: ';31'
 green: ';32'

log = exports.log = (message, color = 'reset', explanation = '') ->
 if Array.isArray color
  c = ''
  for i in color
   c += COLORS[i] ? ''
  color = c
 else
  color = COLORS[color] ? COLORS.reset
 color = "\x1B[0#{color}m"
 reset = "\x1B[0#{COLORS.reset}m"
 color = '' if process.env.NODE_DISABLE_COLORS
 reset = '' if process.env.NODE_DISABLE_COLORS

 console.log color + message + reset + ' ' + (explanation or '')

exports.finish = ->
 n = 0
 errors = []
 for e in arguments
  if e?
   if (typeof e) isnt 'number'
    errors.push e
    n++
   else
    n += e

 if n is 0
  log '(0) error(s)', ['green', 'bold']
 else
  for e in errors
   log "#{e}", 'red'
  log "(#{n}) error(s)", ['red', 'bold']


watch = exports.watch = (files, callback, args)->
 return unless options.watch
 for file in files
  do (file) ->
   fs.watchFile file, persistent:true, interval:1500 , (curr, prev) ->
    for f in files
     fs.unwatchFile f
    log "* #{file}"
    try
     callback.apply null, args
    catch err
     log "Error watching: #{src}"

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
    log " - #{src}", 'red'
    log "  ^ #{e.message} (col #{e.column})", 'red'
    log "    Near: #{e.extract}", 'red'
    callback 1
    return

   cssCode = cssCode.css

   if options.map
    url = "#{map.substr BUILD.length}"
    cssCode = "#{cssCode}\n/*# sourceMappingURL=#{url}*/\n"

   fs.writeFileSync dest, cssCode
   log " - #{src}" unless options.quiet
   callback 0
 catch err
  log " - #{src}", 'red'
  log "  ^ #{err.message} (col #{err.column})", 'red'
  log "    Near: #{err.extract}", 'red'
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
  log " - #{src}" unless options.quiet
  watch [src], js, [src, dest]
  return 0
 catch err
  log " - #{src}", 'red'
  log "   ^ #{err}", 'red'
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
   log " - #{src}" unless options.quiet
   all += jsCode
  catch err
   log " - #{src}", 'red'
   log "   ^ #{err}", 'red'
   e++

 if e is 0
  try
   final = uglify.minify all, fromString: true
   fs.writeFileSync dest, final.code
  catch err
   log " - #{dest}", 'red'
   log "   ^ #{err}", 'red'
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


