#!/usr/bin/env coffee

require './lib/mod/mod'

Weya = require './lib/weya/weya'
Weya.Base = require './lib/weya/base'
YAML = require 'yamljs'
fs = require 'fs'
jsdom = require 'jsdom'
toc = require './toc'

Mod.set 'Weya', Weya
Mod.set 'Weya.Base', Weya.Base

require './coffee/parser'
require './coffee/nodes'
require './coffee/reader'

argv = require 'optimist'
 .usage 'DocScript parser.\n Usage: $0'
 .demand ['b', 'o']
 .alias 'b', 'book'
 .describe 'b', 'YAML book'
 .alias 'o', 'output'
 .describe 'o', 'Output directory'
 .argv

data = YAML.parse "#{fs.readFileSync argv.book}"

Mod.require 'Docscript.Parser',
 (Parser) ->
  jsdom.env '<div id="toc"></div>', (err, window) ->
   Weya.setApi document: window.document
   tocElem = window.document.getElementById 'toc'
   toc.render data, tocElem
   output = toc.html
    title: data.title
    toc: tocElem.innerHTML

   fs.writeFileSync "./#{argv.output}/toc.html", output


Mod.initialize()
