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
   @link href: "css/fonts.css", rel: "stylesheet"
   @link href: "css/style.css", rel: "stylesheet"

  @body ->
   @div ".container", ->
    @div "#toolbar", ''

   @iframe src: "sandbox.html", width: '100%', height: '500px'

   @script src:"lib/weya/weya.js"
   @script src:"lib/weya/base.js"
   @script src:"lib/mod/mod.js"

   @script src:"js/chrome.js"


exports.html = (options) ->
 options ?= {}
 options.scripts ?= []

 html = Weya.markup context: options, template
 html = "<!DOCTYPE html>#{html}"

 return html


