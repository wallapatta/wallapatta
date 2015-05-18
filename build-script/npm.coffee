util = require './util'
fs = require 'fs'
index = require '../ui-assets/index.coffee'
{spawn, exec} = require 'child_process'

UI_JS = [
 'parser'
 'reader'
 'nodes'
 'static'
 'render'
]
UI_LESS = [
 'style'
 'paginate'
]

FILES = [
 'package.json'
 'readme.md'
 'LICENSE'
]

exports.npm = (callback) ->
 commands = []
 if fs.existsSync "#{NPM}/js"
  commands.push "rm -r #{NPM}/*"

 commands = commands.concat [
  "mkdir #{NPM}/css"
  "mkdir #{NPM}/lib"
  "mkdir #{NPM}/js"
  "mkdir #{NPM}/templates"
  "mkdir #{NPM}/build"
 ]

 commands = commands.concat [
  "cp -r #{BUILD}/lib/* #{NPM}/lib/"
  "rm -r #{NPM}/lib/CodeMirror"
  "coffee -c -o #{NPM}/templates templates/*.coffee"
  "coffee -c -o #{NPM}/ *.coffee"
  "cp -r #{BUILD}/* #{NPM}/build/"
 ]

 for file in UI_LESS
  commands.push "cp #{BUILD}/css/#{file}.css #{NPM}/css/"
 for file in UI_JS
  commands.push "cp #{BUILD}/js/#{file}.js #{NPM}/js/"
 for file in FILES
  commands.push "cp #{file} #{NPM}/"

 commands.push "echo \"#! /usr/bin/env node\" | cat - #{NPM}/cli.js > #{NPM}/temp.js"
 commands.push "mv #{NPM}/temp.js #{NPM}/cli.js"
 commands.push "chmod +x #{NPM}/cli.js"

 exec commands.join('&&'), (e, stderr, stdout) ->
  util.log stderr.trim(), 'red'
  util.log stdout.trim(), 'red'
  e = (if e? then 1 else 0)

  callback e

