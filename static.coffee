VERSION = 9

Weya = require './lib//weya/weya'

UI_JS = [
 'static'
 'parser'
 'reader'
 'nodes'
]

template = ->
 @html ->
  @head ->
   @meta charset: "utf-8"
   @title "Docscript"
   @meta name: "viewport", content: "width=device-width, initial-scale=1.0"
   @meta name: "apple-mobile-web-app-capable", content:"yes"
   @link
    href: 'http://fonts.googleapis.com/css?family=Source+Sans+Pro:200,300,400,600,700,900,200italic,300italic,400italic,600italic,700italic,900italica'
    rel: 'stylesheet'
    type: 'text/css'
   @link
    href: 'http://fonts.googleapis.com/css?family=Open+Sans:300italic,400italic,600italic,700italic,800italic,400,300,600,700,800'
    rel: 'stylesheet'
    type: 'text/css'
   @link href: "lib/bootstrap/css/bootstrap.min.css", rel: "stylesheet"
   @link href: "lib/fontawesome/css/font-awesome.min.css", rel: "stylesheet"
   @link href: "lib/codemirror/codemirror.css", rel: "stylesheet"
   @link href: "css/style.css", rel: "stylesheet"
   @link rel: "shortcut icon", href: "img/favicon.ico", type: "image/x-icon"
   @script '''
     (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
     (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
     m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
     })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

     ga('create', 'UA-37809145-1', 'auto');
     ga('send', 'pageview');
   '''

  @body ->
   @div ".container", ->
    @div ".row.docscript", ->
     @div "#main.col-md-9", "###MAIN###"
     @div "#sidebar.col-md-3", "###SIDEBAR###"

   @div "#code", style: {display: 'none'}, "###CODE###"

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
 html = html.replace '###CODE###', options.code

 html = "<!DOCTYPE html>#{html}"

 return html


