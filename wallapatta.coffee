#!/usr/bin/env coffee

require './lib/mod/mod'

Weya = require './lib/weya/weya'
Weya.Base = require './lib/weya/base'
fs = require 'fs'
jsdom = require 'jsdom'
template = require './templates/page'

Mod.set 'fs', fs
Mod.set 'jsdom', require 'jsdom'
Mod.set 'Weya', Weya
Mod.set 'Weya.Base', Weya.Base

require './file'

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
 .alias 't', 'title'
 .describe 't', 'Title'
 .default 't', 'Created with Wallapatta'
 .alias 'h', 'template'
 .describe 'h', 'Template'
 .default 'h', './templates/page'
 .argv

Mod.require 'Wallapatta.File',
 (FileRender) ->
   FileRender
    file: argv.input
    template: argv.template
    output: argv.output
    options:
     title: argv.title

Mod.initialize()
