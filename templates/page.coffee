VERSION = 9

Weya = require '../lib//weya/weya'

UI_JS = [
 'static'
 'parser'
 'reader'
 'nodes'
 'render'
]

template = ->
 title = @$.title
 @html ->
  @head ->
   @meta charset: "utf-8"
   if title?
    @title title
   else
    @title "Made with Wallapatta"
   @meta name: "viewport", content: "width=device-width, initial-scale=1.0"
   @meta name: "apple-mobile-web-app-capable", content:"yes"
   @link
    href: 'http://fonts.googleapis.com/css?family=Raleway:400,100,200,300,500,600,700,800,900'
    rel: 'stylesheet'
    type: 'text/css'

   @link href: "lib/skeleton/css/skeleton.css", rel: "stylesheet"
   @link href: "lib/highlightjs/styles/default.css", rel: "stylesheet"
   @link href: "css/style.css", rel: "stylesheet"

  @body ->
   @div ".container.wallapatta-container", ->
    @div ".wallapatta", ->
     if title?
      @h1 ".title", title
     @div ".row", ->
      @div ".wallapatta-main.nine.columns", "###MAIN###"
      @div ".wallapatta-sidebar.three.columns", "###SIDEBAR###"
      @div style: {display: 'none'}, "###CODE###"

   @script src: "lib/highlightjs/highlight.pack.js"

   @script src:"lib/weya/weya.js"
   @script src:"lib/weya/base.js"
   @script src:"lib/mod/mod.js"

   for file in @$.scripts
    @script src: "js/#{file}.js?v=#{VERSION}"

exports.html = (options) ->
 options ?= {}
 options.scripts ?= UI_JS

 html = Weya.markup context: options, template

 html = html.replace '###MAIN###', options.main
 html = html.replace '###SIDEBAR###', options.sidebar
 html = html.replace '###CODE###',
  "<div class='wallapatta-code'>#{options.code}</div>"

 html = "<!DOCTYPE html>#{html}"

 return html


