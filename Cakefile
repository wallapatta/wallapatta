require 'coffee-script/register'
GLOBAL.BUILD = 'build'
GLOBAL.NPM = 'npm'

util = require './build-script/util'
ui = require './build-script/ui'
npm = require './build-script/npm'
fs = require 'fs'
{spawn, exec} = require 'child_process'

option '-q', '--quiet',    'Only diplay errors'
option '-w', '--watch',    'Watch files for change and automatically recompile'
option '-c', '--compress', 'Compress files via YUIC'
option '-i', '--inplace',  'Compress files in-place'
option '-m', '--map',  'Source map'

task 'clean', "Cleans up build directory", (opts) ->
 commands = []
 if fs.existsSync "#{BUILD}"
  commands.push "rm #{BUILD}/ -r"
 if fs.existsSync "#{NPM}"
  commands.push "rm #{NPM}/ -r"

 commands = commands.concat [
  "mkdir #{BUILD}"
  "mkdir #{NPM}"
 ]

 exec commands.join('&&'), (err, stderr, stdout) ->
  if err?
   util.log stderr.trim(), 'red'
   util.log stdout.trim(), 'red'
   err = 1

  util.finish err

task 'build', "Build all", (opts) ->
 GLOBAL.options = opts
 buildUi (e1) ->
  buildNPM (e2) ->
   util.finish e1 + e2

task 'build:ui', "Build UI", (opts) ->
 GLOBAL.options = opts
 buildUi (e) ->
  util.finish e

buildUi = (callback) ->
 ui.assets (e1) ->
  ui.js (e2) ->
   callback e1 + e2

buildNPM = (callback) ->
 npm.npm callback

task 'build:ui-js', "Build UI js", (opts) ->
 GLOBAL.options = opts
 ui.js util.finish

task 'build:ui-assets', "Build CSS, index.html, worker.js and copy assets", (opts) ->
 GLOBAL.options = opts
 ui.assets util.finish

