VERSION = 9

Weya = require '../lib//weya/weya'

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
   @link href: "lib/Font-Awesome/css/font-awesome.min.css", rel: "stylesheet"
   @link href: "lib/skeleton/css/skeleton.css", rel: "stylesheet"
   @link href: "lib/CodeMirror/lib/codemirror.css", rel: "stylesheet"
   @link href: "lib/CodeMirror/addon/fold/foldgutter.css", rel: "stylesheet"
   @link href: "lib/highlightjs/styles/default.css", rel: "stylesheet"
   @link href: "css/style.css", rel: "stylesheet"
   @link href: "css/editor.css", rel: "stylesheet"
   @script '''
     (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
     (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
     m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
     })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

     ga('create', 'UA-37809145-1', 'auto');
     ga('send', 'pageview');
   '''

  @body ->
   @script src: "lib/highlightjs/highlight.pack.js"

   @script src:"lib/CodeMirror/lib/codemirror.js"
   @script src:"js/codemirror-syntax.js"
   @script src:"lib/CodeMirror/mode/xml/xml.js"
   @script src:"lib/CodeMirror/addon/fold/foldcode.js"
   @script src:"lib/CodeMirror/addon/fold/foldgutter.js"
   @script src:"lib/CodeMirror/addon/fold/indent-fold.js"

   @script src:"lib/weya/weya.js"
   @script src:"lib/weya/base.js"
   @script src:"lib/mod/mod.js"

   @script src:"js/main.js"
   @script src:"js/editor.js"
   @script src:"js/parser.js"
   @script src:"js/reader.js"
   @script src:"js/nodes.js"
   @script src:"js/sample.js"
   @script src:"js/render.js"
   @script src:"js/chrome.js"


exports.html = (options) ->
 options ?= {}
 options.scripts ?= []

 html = Weya.markup context: options, template
 html = "<!DOCTYPE html>#{html}"

 return html


