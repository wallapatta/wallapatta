FS_UTIL = require './fs_util'
LOG = (require '../log').log
PATH = require 'path'
COMPILE_COFFEE_DIR = (require './util').jsDir
COMPILE_CSS = (require '../util').css
COMPILE_CSS_FILE = (file, callback) ->
 COMPILE_CSS "ui-assets/less/",
  "ui-assets/less/#{file}.less"
  "#{BUILD}/css/#{file}.css"
  callback

UI_LESS = [
 'style'
 'paginate'
 'fonts'
]

exports.assets = ->
 try
  if FS_UTIL.exists "#{BUILD}/lib"
   FS_UTIL.rm_r "#{BUILD}/lib"
  if FS_UTIL.exists "#{BUILD}/css"
   FS_UTIL.rm_r "#{BUILD}/css"
  if FS_UTIL.exists "#{BUILD}/assets"
   FS_UTIL.rm_r "#{BUILD}/assets"

  FS_UTIL.mkdir "#{BUILD}/css"
  FS_UTIL.mkdir "#{BUILD}/assets"
  FS_UTIL.mkdir "#{BUILD}/lib"
  FS_UTIL.mkdir "#{BUILD}/lib/weya"
  FS_UTIL.mkdir "#{BUILD}/lib/mod"

  FS_UTIL.cp_r "ui-assets/lib", "#{BUILD}/lib"
  FS_UTIL.cp_r "ui-assets/assets", "#{BUILD}/assets"
 catch e
  LOG e, 'red'
  return 1

 err = 0

 err += COMPILE_COFFEE_DIR "lib/weya/", "#{BUILD}/lib/weya"
 err += COMPILE_COFFEE_DIR "lib/mod/", "#{BUILD}/lib/mod"

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
  if FS_UTIL.exists "#{BUILD}/js"
   FS_UTIL.rm_r "#{BUILD}/js"
  FS_UTIL.mkdir "#{BUILD}/js"
 catch e
  LOG e, 'red'
  return 1

 COMPILE_COFFEE_DIR "js", "#{BUILD}/js"

