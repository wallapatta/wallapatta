VERSION = 9

Weya = require '../lib//weya/weya'

template = ->
 @html ->
  @head ->
   @meta charset: "utf-8"
   @title "Forestpin Lite App"
   @meta name: "viewport", content: "width=device-width, initial-scale=1.0"
   @meta name: "apple-mobile-web-app-capable", content:"yes"

   @link href: "lib/bootstrap/css/bootstrap.min.css", rel: "stylesheet"
   @link href: "lib/fontawesome/css/font-awesome.min.css", rel: "stylesheet"
   @link href: "css/style.css", rel: "stylesheet"
   @link rel: "shortcut icon", href: "img/favicon.ico", type: "image/x-icon"

  @body ->
   @script src:"lib/d3.v3.min.js"

   @script src:"lib/weya/weya.js"
   @script src:"lib/weya/base.js"
   @script src:"lib/weya/router.js"
   @script src:"lib/mod/mod.js"

   for file in @$.scripts
    @script src: "#{file}?v=#{VERSION}"

exports.html = (options) ->
 options ?= {}
 options.scripts ?= []

 html = Weya.markup context: options, template
 html = "<!DOCTYPE html>#{html}"

 return html


