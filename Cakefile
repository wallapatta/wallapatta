require 'coffee-script/register'
GLOBAL.BUILD = 'build'

util = require './build-script/util'
ui = require './build-script/ui'
npm = require './build-script/npm'
chrome = require './build-script/chrome'
fs = require 'fs'
{spawn, exec} = require 'child_process'

option '-q', '--quiet',    'Only diplay errors'
option '-w', '--watch',    'Watch files for change and automatically recompile'
option '-c', '--compress', 'Compress files via YUIC'
option '-i', '--inplace',  'Compress files in-place'
option '-m', '--map',  'Source map'

task 'clean', "Cleans up build directory", (opts) ->
 CLEAN()

task 'build:npm', "Build npm", (opts) ->
 GLOBAL.options = opts
 CLEAN ->
  buildNPM (e) ->
   util.finish e

task 'build:ui', "Build UI", (opts) ->
 GLOBAL.options = opts
 buildUi (e) ->
  util.finish e

task "build:chrome", "Build Chrome", (opts) ->
 GLOBAL.options = opts
 buildChrome (e) ->
  util.finish e

buildChrome = (callback) ->
 chrome.assets (e1) ->
  chrome.js (e2) ->
   callback e1 + e2

buildUi = (callback) ->
 ui.assets (e1) ->
  ui.js (e2) ->
   callback e1 + e2

buildNPM = (callback) ->
 ui.assets (e1) ->
  ui.js (e2) ->
   npm.npm (e3) ->
    callback e1 + e2 + e3

CLEAN = (callback) ->
 commands = []
 if fs.existsSync "#{BUILD}"
  commands.push "rm -r #{BUILD}/"

 commands = commands.concat [
  "mkdir #{BUILD}"
 ]

 exec commands.join('&&'), (err, stderr, stdout) ->
  if err?
   util.log stderr.trim(), 'red'
   util.log stdout.trim(), 'red'
   err = 1

  util.finish err
  callback?()


