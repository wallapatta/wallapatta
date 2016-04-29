VERSION = 9

Weya = require '../lib//weya/weya'

template = ->
 @html ->
  @head ->
   @meta charset: "utf-8"
   @title "Wallapatta"
   @meta name: "viewport", content: "width=device-width, initial-scale=1.0"
   @meta name: "apple-mobile-web-app-capable", content:"yes"
   @link href: "lib/Font-Awesome/css/font-awesome.css", rel: "stylesheet"
   @link href: "lib/skeleton/css/skeleton.css", rel: "stylesheet"
   @link href: "lib/CodeMirror/lib/codemirror.css", rel: "stylesheet"
   @link href: "lib/CodeMirror/addon/fold/foldgutter.css", rel: "stylesheet"
   @link href: "lib/highlightjs/styles/default.css", rel: "stylesheet"
   @link href: "css/fonts.css", rel: "stylesheet"
   @link href: "css/style.css", rel: "stylesheet"
   @link href: "css/editor.css", rel: "stylesheet"

  @body ->
   @script src: "lib/highlightjs/highlight.pack.js"

   @script src:"lib/CodeMirror/lib/codemirror.js"
   @script src:"js/codemirror-syntax.js"
   @script src:"lib/CodeMirror/mode/xml/xml.js"
   @script src:"lib/CodeMirror/mode/javascript/javascript.js"
   @script src:"lib/CodeMirror/mode/coffeescript/coffeescript.js"
   @script src:"lib/CodeMirror/addon/fold/foldcode.js"
   @script src:"lib/CodeMirror/addon/fold/foldgutter.js"
   @script src:"lib/CodeMirror/addon/fold/indent-fold.js"

   @script src:"lib/coffeescript/coffee-script.js"

   @script src:"lib/weya/weya.js"
   @script src:"lib/weya/base.js"
   @script src:"lib/mod/mod.js"

   @script src:"assets/google_10000_words.js"

   @script src:"js/main.js"
   @script src:"js/editor.js"
   @script src:"js/parser.js"
   @script src:"js/reader.js"
   @script src:"js/nodes.js"
   @script src:"js/sample.js"
   @script src:"js/render.js"
   @script src:"js/sandbox.js"


exports.html = (options) ->
 options ?= {}
 options.scripts ?= []

 html = Weya.markup context: options, template
 html = "<!DOCTYPE html>#{html}"

 return html


