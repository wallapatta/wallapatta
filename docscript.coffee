#!/usr/bin/env coffee

require './lib/mod/mod'

Weya = require './lib/weya/weya'
Weya.Base = require './lib/weya/base'
fs = require 'fs'
jsdom = require 'jsdom'
page = require './static'

Mod.set 'Weya', Weya
Mod.set 'Weya.Base', Weya.Base

#TODO
require './coffee/parser'
require './coffee/nodes'
require './coffee/reader'

argv = require 'optimist'
 .usage 'DocScript parser.\n Usage: $0'
 .demand ['i']
 .alias 'i', 'input'
 .describe 'i', 'Input file'
 .argv

input = "#{fs.readFileSync argv.input}"

Mod.require 'Docscript.Parser',
 (Parser) ->
  parser = new Parser text: input
  parser.parse()
  jsdom.env '<div id="main"></div><div id="sidebar"></div>', (err, window) ->
   Weya.setApi document: window.document
   main = window.document.getElementById 'main'
   sidebar = window.document.getElementById 'sidebar'
   parser.render main, sidebar
   output = page.html
    main: main.innerHTML
    sidebar: sidebar.innerHTML
    code: input

   fs.writeFileSync './build/static.html', output


Mod.initialize()
