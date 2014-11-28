#!/usr/bin/env coffee

require './lib/mod/mod'

Weya = require './lib/weya/weya'
Weya.Base = require './lib/weya/base'
fs = require 'fs'
jsdom = require 'jsdom'
template = require './templates/page'

Mod.set 'Weya', Weya
Mod.set 'Weya.Base', Weya.Base

require './coffee/parser'
require './coffee/nodes'
require './coffee/reader'

argv = require 'optimist'
 .usage 'Wallapatta parser.\n Usage: $0'
 .demand ['i', 'o']
 .alias 'i', 'input'
 .describe 'i', 'Input file'
 .alias 'o', 'output'
 .describe 'o', 'Output file'
 .argv

input = "#{fs.readFileSync argv.input}"

Mod.require 'Wallapatta.Parser',
 (Parser) ->
  parser = new Parser text: input
  parser.parse()
  jsdom.env '<div id="main"></div><div id="sidebar"></div>', (err, window) ->
   Weya.setApi document: window.document
   main = window.document.getElementById 'main'
   sidebar = window.document.getElementById 'sidebar'
   parser.render main, sidebar
   output = template.html
    main: main.innerHTML
    sidebar: sidebar.innerHTML
    code: input

   fs.writeFileSync "#{argv.output}", output


Mod.initialize()
