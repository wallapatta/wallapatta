#!/usr/bin/env coffee

require './lib/mod/mod'

Weya = require './lib/weya/weya'
Weya.Base = require './lib/weya/base'
fs = require 'fs'
jsdom = require 'jsdom'
template = require './templates/page'
YAML = require 'yamljs'

Mod.set 'fs', fs
Mod.set 'jsdom', jsdom
Mod.set 'Weya', Weya
Mod.set 'Weya.Base', Weya.Base

require './file'
require './paginate'

require './coffee/parser'
require './coffee/nodes'
require './coffee/reader'

argv = require 'optimist'
 .usage 'Wallapatta parser.\n Usage: $0'
 .demand ['file', 'output']

 .describe 'file', 'Single wallapatta file'

 .describe 'output', 'Output directory'

 .describe 'title', 'Title of a single document'
 .default 'title', 'Created with Wallapatta'

 .describe 'template', 'Template'
 .default 'template', './templates/page'

 .describe 'blog', 'Blog YAML file'
 .describe 'book', 'Book YAML file'

 .describe 'posts', 'Posts per page'

 .argv


Mod.require 'jsdom',
 'Wallapatta.File'
 'Wallapatta.Paginate'
 (jsdom, FileRender, Paginate) ->
   FileRender
    file: argv.input
    template: argv.template
    output: argv.output
    options:
     title: argv.title

Mod.initialize()
