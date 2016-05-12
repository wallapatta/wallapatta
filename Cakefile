require 'coffee-script/register'
GLOBAL.BUILD = 'build'

util = require './build-script/util'
ui = require './build-script/ui'
npm = require './build-script/npm'
electron = require './build-script/electron'
fs = require 'fs'
{spawn, exec} = require 'child_process'

option '-q', '--quiet',    'Only diplay errors'
option '-w', '--watch',    'Watch files for change and automatically recompile'
option '-c', '--compress', 'Compress files via YUIC'

task 'clean', "Cleans up build directory", (opts) ->
 util.finish CLEAN()

task 'build:npm', "Build npm", (opts) ->
 GLOBAL.options = opts
 CLEAN()
 ui.assets (e1) ->
  ui.js (e2) ->
   npm.npm (e3) ->
   util.finish e1 + e2 + e3

task "build:electron", "Build Electron", (opts) ->
 GLOBAL.options = opts
 ui.assets (e1) ->
  ui.js (e2) ->
   util.finish e1 + e2

CLEAN = ->
 try
  if FS_UTIL.exists BUILD
   FS_UTIL.rm_r BUILD
  FS_UTIL.mkdir "#{BUILD}"
 catch e
  util.log stderr.trim(), 'red'
  util.log stdout.trim(), 'red'
  return 1

 return 0

