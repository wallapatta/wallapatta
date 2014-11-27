VERSION = 9

Weya = require '../lib//weya/weya'

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
    href: 'http://fonts.googleapis.com/css?family=Lato:100,300,400,700'
    rel: 'stylesheet'
    type: 'text/css'
   @link href: "lib/bootstrap/css/bootstrap.min.css", rel: "stylesheet"
   @link href: "lib/fontawesome/css/font-awesome.min.css", rel: "stylesheet"
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
   @div ".container.docscript-container", ->
    for post, i in @$.posts
     @div ".row.docscript", ->
      @div ".docscript-main.col-xs-9", "###MAIN#{i}###"
      @div ".docscript-sidebar.col-xs-3", "###SIDEBAR#{i}###"
      @div ".docscript-code", style: {display: 'none'}, "###CODE#{i}###"

   @script src:"lib/weya/weya.js"
   @script src:"lib/weya/base.js"
   @script src:"lib/mod/mod.js"

   for file in @$.scripts
    @script src: "js/#{file}.js?v=#{VERSION}"

exports.html = (options) ->
 options ?= {}
 options.scripts ?= UI_JS

 html = Weya.markup context: options, template

 for post, i in options.posts
  html = html.replace "###MAIN#{i}###", post.main
  html = html.replace "###SIDEBAR#{i}###", post.sidebar
  html = html.replace "###CODE#{i}###", post.code

 html = "<!DOCTYPE html>#{html}"

 return html


