require 'coffee-script/register'
GLOBAL.BUILD = 'build'

LOG = require './build-script/log'
UI = require './build-script/ui'
npm = require './build-script/npm'
ELECTRON = require './build-script/electron'
fs = require 'fs'
{spawn, exec} = require 'child_process'

option '-q', '--quiet',    'Only diplay errors'
option '-w', '--watch',    'Watch files for change and automatically recompile'
option '-c', '--compress', 'Compress files via YUIC'

task 'clean', "Cleans up build directory", (opts) ->
 LOG.finish CLEAN()

task 'build:npm', "Build npm", (opts) ->
 GLOBAL.options = opts
 CLEAN()
 ui.assets (e1) ->
  ui.js (e2) ->
   npm.npm (e3) ->
   LOG.finish e1 + e2 + e3

task "build:electron", "Build Electron", (opts) ->
 GLOBAL.options = opts
 e = 0
 e += UI.assets()
 e += UI.js()
 UI.css (e1) ->
  e += ELECTRON.assets()
  e += ELECTRON.js()
  e += ELECTRON.app()
  ELECTRON.css (e2) ->
   LOG.finish e + e1 + e2

CLEAN = ->
 try
  if FS_UTIL.exists BUILD
   FS_UTIL.rm_r BUILD
  FS_UTIL.mkdir "#{BUILD}"
  FS_UTIL.mkdir "#{BUILD}/app"
 catch e
  LOG.log e.message, 'red'
  return 1

 return 0

