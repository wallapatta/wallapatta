FS_UTIL = require './fs_util'
LOG = (require './log').log
PATH = require 'path'
COMPILE_COFFEE_DIR = (require './util').jsDir
COMPILE_CSS = (require './util').css
WATCH = (require './util').watch
COMPILE_CSS_FILE = (file, callback) ->
 COMPILE_CSS "ui-assets/less/",
  "ui-assets/less/#{file}.less"
  "#{APP}/css/#{file}.css"
  callback

UI_LESS = [
 'style'
 'paginate'
 'fonts'
 'theme'
]

exports.assets = ->
 try
  if FS_UTIL.exists "#{APP}/lib"
   FS_UTIL.rm_r "#{APP}/lib"
  if FS_UTIL.exists "#{APP}/css"
   FS_UTIL.rm_r "#{APP}/css"
  if FS_UTIL.exists "#{APP}/assets"
   FS_UTIL.rm_r "#{APP}/assets"

  FS_UTIL.mkdir "#{APP}/css"
  FS_UTIL.mkdir "#{APP}/assets"
  FS_UTIL.mkdir "#{APP}/lib"
  FS_UTIL.mkdir "#{APP}/lib/weya"
  FS_UTIL.mkdir "#{APP}/lib/mod"

  FS_UTIL.cp_r "ui-assets/lib", "#{APP}/lib"
  FS_UTIL.cp_r "ui-assets/assets", "#{APP}/assets"
 catch e
  LOG e, 'red'
  return 1

 err = 0

 err += COMPILE_COFFEE_DIR "lib/weya/", "#{APP}/lib/weya"
 err += COMPILE_COFFEE_DIR "lib/mod/", "#{APP}/lib/mod"

 return err

_css = exports.css = (callback) ->
 filesToWatch = UI_LESS

 filesToWatch = ("ui-assets/less/#{f}.less" for f in filesToWatch)

 COMPILE_CSS_FILE 'style', (e1) ->
  COMPILE_CSS_FILE 'paginate', (e2) ->
   COMPILE_CSS_FILE 'fonts', (e3) ->
    COMPILE_CSS_FILE 'theme', (e4) ->
     WATCH filesToWatch, _css, []
     callback? e1 + e2 + e3


exports.js = ->
 try
  if FS_UTIL.exists "#{APP}/js"
   FS_UTIL.rm_r "#{APP}/js"
  FS_UTIL.mkdir "#{APP}/js"
 catch e
  LOG e, 'red'
  return 1

 COMPILE_COFFEE_DIR "js", "#{APP}/js"

