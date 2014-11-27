#!/usr/bin/env coffee

require './lib/mod/mod'

Weya = require './lib/weya/weya'
Weya.Base = require './lib/weya/base'
YAML = require 'yamljs'
toc = require './templates/toc'
fs = require 'fs'

Mod.set 'fs', fs
Mod.set 'jsdom', require 'jsdom'
Mod.set 'Weya', Weya
Mod.set 'Weya.Base', Weya.Base

require './file'

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

Mod.require 'jsdom',
 'Docscript.File'
 (jsdom, FileRender) ->
  render = (options) ->
   FileRender
    file: options.file
    template: './templates/page'
    output: "#{argv.output}/#{options.id}.html"

   if options.content?
    for i in options.content
     render i


  jsdom.env '<div id="toc"></div>', (err, window) ->
   Weya.setApi document: window.document
   tocElem = window.document.getElementById 'toc'
   toc.render data, tocElem
   output = toc.html
    title: data.title
    toc: tocElem.innerHTML

   fs.writeFileSync "./#{argv.output}/toc.html", output

   for i in data.content
    render i



Mod.initialize()
