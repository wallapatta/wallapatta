require 'coffee-script/register'
global.APP = 'app'
global.BUILD = 'build'
global.DIST = 'dist'


LOG = require './build-script/log'
UI = require './build-script/ui'
FS_UTIL = require './build-script/fs_util'
#npm = require './build-script/npm'
ELECTRON = require './build-script/electron'

option '-q', '--quiet',    'Only diplay errors'
option '-w', '--watch',    'Watch files for change and automatically recompile'
option '-c', '--compress', 'Compress files via YUIC'

task 'clean', "Cleans up build directory", (opts) ->
 LOG.finish CLEAN()

task 'npm', "Build npm", (opts) ->
 global.options = opts
 CLEAN()
 ui.assets (e1) ->
  ui.js (e2) ->
   npm.npm (e3) ->
   LOG.finish e1 + e2 + e3

task "electron", "Build Electron", (opts) ->
 global.options = opts
 e = 0
 e += UI.assets()
 e += UI.js()
 UI.css (e1) ->
  console.log 'ui'
  e += ELECTRON.assets()
  e += ELECTRON.html()
  e += ELECTRON.app()
  ELECTRON.css (e2) ->
   LOG.finish e + e1 + e2

CLEAN = ->
 try
  if FS_UTIL.exists BUILD
   FS_UTIL.rm_r BUILD
  FS_UTIL.mkdir "#{BUILD}"
  if FS_UTIL.exists APP
   FS_UTIL.rm_r APP
  FS_UTIL.mkdir "#{APP}"
  if FS_UTIL.exists DIST
   FS_UTIL.rm_r DIST
 catch e
  LOG.log e.message, 'red'
  return 1

 return 0

