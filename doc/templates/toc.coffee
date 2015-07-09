VERSION = 9

Weya = require './weya/weya'

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
   @link href: "css/style.css", rel: "stylesheet"
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
    @h1 "Wallapatta"
    @div ".toc", ->
     renderChapters = (list) ->
      return unless list?
      @ol ->
       for article in list
        @li ->
         if article.file?
          @a href: "#{article.id}.html", article.title
         else
          @span article.title

         renderChapters.call this,  list.content

     renderChapters.call this, @$.chapters

exports.html = (options) ->
 html = Weya.markup context: options, template

 html = "<!DOCTYPE html>#{html}"

 return html

