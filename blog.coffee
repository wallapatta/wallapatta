#!/usr/bin/env coffee

require './lib/mod/mod'

Weya = require './lib/weya/weya'
Weya.Base = require './lib/weya/base'
YAML = require 'yamljs'
blog = require './templates/blog'
fs = require 'fs'

Mod.set 'fs', fs
Mod.set 'jsdom', require 'jsdom'
Mod.set 'Weya', Weya
Mod.set 'Weya.Base', Weya.Base

require './file'
require './paginate'

require './coffee/parser'
require './coffee/nodes'
require './coffee/reader'

argv = require 'optimist'
 .usage 'DocScript parser.\n Usage: $0'
 .demand ['b', 'o']
 .alias 'b', 'blog'
 .describe 'b', 'YAML book'
 .alias 'o', 'output'
 .describe 'o', 'Output directory'
 .argv

data = YAML.parse "#{fs.readFileSync argv.blog}"

Mod.require 'Docscript.File',
 'Docscript.Paginate'
 (FileRender, Paginate) ->
  renderPost = (options) ->
   FileRender
    input: options.file
    page: './templates/page'
    output: "#{argv.output}/#{options.id}.html"

   if options.content?
    for i in options.content
     render i

  inputs = []
  pages = 0

  for i in data
   console.log i
   renderPost i
   inputs.push i
   if inputs.length is 3
    Paginate
     input: inputs
     page: pages
     template: './templates/blog'
     output: argv.output
    pages++
    inputs = []

  if inputs.length > 0
   Paginate
    input: inputs
    page: pages
    template: './templates/blog'
    output: argv.output
   pages++
   inputs = []


Mod.initialize()
