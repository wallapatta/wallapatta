util = require './util'
fs = require 'fs'
index = require '../ui-assets/index.coffee'
{spawn, exec} = require 'child_process'

FILES = [
 'package.json'
 'readme.md'
 'LICENSE'
]

exports.npm = (callback) ->
 commands = []

 commands = commands.concat [
  "mkdir #{BUILD}/templates"
  "mkdir #{BUILD}/build"
 ]

 commands = commands.concat [
  "rm -r #{BUILD}/lib/CodeMirror"
  "cp -r #{BUILD}/css #{BUILD}/build/css"
  "cp -r #{BUILD}/js #{BUILD}/build/js"
  "cp -r #{BUILD}/lib #{BUILD}/build/lib"
  "coffee -c -o #{BUILD}/templates templates/*.coffee"
  "coffee -c -o #{BUILD}/ *.coffee"
 ]

 for file in FILES
  commands.push "cp #{file} #{BUILD}/"

 commands.push "echo \"#! /usr/bin/env node\" | cat - #{BUILD}/cli.js > #{BUILD}/temp.js"
 commands.push "mv #{BUILD}/temp.js #{BUILD}/cli.js"
 commands.push "chmod +x #{BUILD}/cli.js"

 exec commands.join('&&'), (e, stderr, stdout) ->
  util.log stderr.trim(), 'red'
  util.log stdout.trim(), 'red'
  e = (if e? then 1 else 0)

  callback e

