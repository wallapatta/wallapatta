Mod.require 'Docscript.Parser', (Parser) ->
 code = (document.getElementById 'code').textContent
 main = (document.getElementById 'main').textContent
 sidebar = (document.getElementById 'sidebar').textContent

 parser = new Parser text: code
 parser.parse()

document.addEventListener 'DOMContentLoaded', ->
 Mod.set 'Weya', Weya
 Mod.set 'Weya.Base', Weya.Base

 Mod.initialize()
