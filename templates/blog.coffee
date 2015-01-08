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
 @html ->
  @head ->
   @meta charset: "utf-8"
   @title "Wallapatta"
   @meta name: "viewport", content: "width=device-width, initial-scale=1.0"
   @meta name: "apple-mobile-web-app-capable", content:"yes"
   @link
    href: 'http://fonts.googleapis.com/css?family=Raleway:400,100,200,300,500,600,700,800,900'
    rel: 'stylesheet'
    type: 'text/css'
   @link href: "lib/skeleton/css/skeleton.css", rel: "stylesheet"
   @link href: "lib/highlightjs/styles/default.css", rel: "stylesheet"
   @link href: "css/style.css", rel: "stylesheet"
   @link href: "css/paginate.css", rel: "stylesheet"
   @script '''
     (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
     (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
     m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
     })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

     ga('create', 'UA-37809145-1', 'auto');
     ga('send', 'pageview');
   '''

  @body ->
   @div ".container.wallapatta-container", ->
    for post, i in @$.posts
     @div ".wallapatta", ->
      title = post.options.title
      if title?
       @h1 ".title", ->
        @a href: "#{post.options.id}.html", title

      @div ".row", ->
       @div ".wallapatta-main.nine.columns", "###MAIN#{i}###"
       @div ".wallapatta-sidebar.three.columns", "###SIDEBAR#{i}###"
       @div style: {display: 'none'}, "###CODE#{i}###"

    options = @$.options
    if options.pages > 1
     @div ".paginate", ->
      if options.page > 0
       @a ".prev-page.button", href: "page#{options.page}.html", "prev"
      if options.page < options.pages - 1
       @a ".next-page.button", href: "page#{options.page + 2}.html", "next"


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

 for post, i in options.posts
  html = html.replace "###MAIN#{i}###", post.main
  html = html.replace "###SIDEBAR#{i}###", post.sidebar
  html = html.replace "###CODE#{i}###",
   "<div class='wallapatta-code'>#{post.code}</div>"

 html = "<!DOCTYPE html>#{html}"

 return html


