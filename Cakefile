require 'coffee-script/register'
GLOBAL.BUILD = 'build'

util = require './build-script/util'
ui = require './build-script/ui'
fs = require 'fs'
{spawn, exec} = require 'child_process'

option '-q', '--quiet',    'Only diplay errors'
option '-w', '--watch',    'Watch files for change and automatically recompile'
option '-c', '--compress', 'Compress files via YUIC'
option '-i', '--inplace',  'Compress files in-place'
option '-m', '--map',  'Source map'

task 'clean', "Cleans up build directory", (opts) ->
 if fs.existsSync "#{BUILD}"
  commands = ["rm #{BUILD}/ -r"]
 else
  commands = []

 commands = commands.concat [
  "mkdir #{BUILD}"
 ]

 exec commands.join('&&'), (err, stderr, stdout) ->
  if err?
   log stderr.trim(), RED
   log stdout.trim(), RED
   err = 1

  util.finish err

task 'build', "Build all", (opts) ->
 GLOBAL.options = opts
 buildUi (e) ->
  util.finish e

task 'build:ui', "Build UI", (opts) ->
 GLOBAL.options = opts
 buildUi (e) ->
  util.finish e

buildUi = (callback) ->
 ui.assets (e1) ->
  ui.js (e2) ->
   callback e1 + e2

task 'build:ui-js', "Build UI js", (opts) ->
 GLOBAL.options = opts
 ui.js util.finish

task 'build:ui-assets', "Build CSS, index.html, worker.js and copy assets", (opts) ->
 GLOBAL.options = opts
 ui.assets util.finish

