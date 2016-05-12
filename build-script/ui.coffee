FS_UTIL = require './fs_util'
LOG = (require '../log').log
PATH = require 'path'
COMPILE_COFFEE_DIR = (require './util').jsDir
COMPILE_CSS = (require '../util').css
COMPILE_CSS_FILE = (file, callback) ->
 COMPILE_CSS "ui-assets/less/",
  "ui-assets/less/#{file}.less"
  "#{BUILD}/app/css/#{file}.css"
  callback

UI_LESS = [
 'style'
 'paginate'
 'fonts'
]

exports.assets = ->
 try
  if FS_UTIL.exists "#{BUILD}/app/lib"
   FS_UTIL.rm_r "#{BUILD}/app/lib"
  if FS_UTIL.exists "#{BUILD}/app/css"
   FS_UTIL.rm_r "#{BUILD}/app/css"
  if FS_UTIL.exists "#{BUILD}/app/assets"
   FS_UTIL.rm_r "#{BUILD}/app/assets"

  FS_UTIL.mkdir "#{BUILD}/app/css"
  FS_UTIL.mkdir "#{BUILD}/app/assets"
  FS_UTIL.mkdir "#{BUILD}/app/lib"
  FS_UTIL.mkdir "#{BUILD}/app/lib/weya"
  FS_UTIL.mkdir "#{BUILD}/app/lib/mod"

  FS_UTIL.cp_r "ui-assets/lib", "#{BUILD}/app/lib"
  FS_UTIL.cp_r "ui-assets/assets", "#{BUILD}/app/assets"
 catch e
  LOG e, 'red'
  return 1

 err = 0

 err += COMPILE_COFFEE_DIR "lib/weya/", "#{BUILD}/app/lib/weya"
 err += COMPILE_COFFEE_DIR "lib/mod/", "#{BUILD}/app/lib/mod"

 return err

_css = exports.css = (callback) ->
 filesToWatch = UI_LESS

 filesToWatch = ("ui-assets/less/#{f}.less" for f in filesToWatch)

 COMPILE_CSS_FILE 'style', (e1) ->
  COMPILE_CSS_FILE 'paginate', (e2) ->
   COMPILE_CSS_FILE 'fonts', (e3) ->
    util.watch filesToWatch, _css, []
    callback? e1 + e2 + e3


exports.js = ->
 try
  if FS_UTIL.exists "#{BUILD}/app/js"
   FS_UTIL.rm_r "#{BUILD}/app/js"
  FS_UTIL.mkdir "#{BUILD}/app/js"
 catch e
  LOG e, 'red'
  return 1

 COMPILE_COFFEE_DIR "js", "#{BUILD}/app/js"

