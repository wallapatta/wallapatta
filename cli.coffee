#!/usr/bin/env coffee

argv = require 'optimist'
 .usage 'Wallapatta parser.\n Usage: $0'
 .demand ['output']

 .describe 'file', 'Single wallapatta file'

 .describe 'output', 'Output directory'

 .describe 'title', 'Title of a single document'
 .default 'title', 'Created with Wallapatta'

 .describe 'template', 'Template'
 .default 'template', './templates/page'

 .describe 'blog', 'Blog YAML file'
 .describe 'book', 'Book YAML file'

 .describe 'static', 'Copy static files'

 .argv

wallapatta = require './wallapatta'

if argv.file?
 wallapatta.file argv, ->
  console.log 'Compiled'

if argv.book?
 wallapatta.book argv, ->
  console.log 'Compiled'

if argv.blog?
 wallapatta.blog argv, ->
  console.log 'Compiled'

