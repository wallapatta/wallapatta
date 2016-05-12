FS_UTIL = require './fs_util'
LOG = (require '../log').log
PATH = require 'path'
COMPILE_COFFEE_DIR = (require './util').jsDir
COMPILE_CSS = (require '../util').css
COMPILE_CSS_FILE = (file, callback) ->
 COMPILE_CSS "electron/less/",
  "electron/less/#{file}.less"
  "#{BUILD}/css/#{file}.css"
  callback

UI_LESS = [
 'editor'
]

exports.assets = ->
 try
  FS_UTIL.cp_r "electron/lib", "#{BUILD}/lib"
  FS_UTIL.cp_r "electron/ui-assets", "#{BUILD}/assets"
 catch e
  LOG e, 'red'
  return 1
 return 0

exports.html = ->
 try
  htmlCode = (require '../electron/html/index').html()
  fs.writeFileSync "#{BUILD}/index.html", htmlCode
  LOG " - index.html" unless options.quiet
 catch err
  LOG " - index.html", 'red'
  LOG "  ^ #{err}", 'red'
  return 1

 return 0

_css = exports.css = (callback) ->
 filesToWatch = UI_LESS

 filesToWatch = ("electron/less/#{f}.less" for f in filesToWatch)

 COMPILE_CSS_FILE 'editor', (e1) ->
  util.watch filesToWatch, _css, []
  callback? e1


exports.app = ->
 err = 0
 err += COMPILE_COFFEE_DIR "electron/js", "#{BUILD}"
 err +=  COMPILE_COFFEE_DIR "electron/ui", "#{BUILD}/js"
 return err if err > 0

 #Move app folder
 try
  FS_UTIL.mv "#{BUILD}", "temp"
  FS_UTIL.mkdir "#{BUILD}"
  FS_UTIL.mv "temp", "#{BUILD}/app"
 catch e
  LOG e, 'red'
  return 1

 return 0

 try
  FS_UTIL.cp "electron/app.json", "#{BUILD}/app/package.json"
  FS_UTIL.cp "electron/build.json", "#{BUILD}/package.json"
  FS_UTIL.mkdir "#{BUILD}/build"
  FS_UTIL.cp_r "electron//assets", "#{BUILD}/build"
 catch e
  LGO e, 'red'
  return 1

 return 0

