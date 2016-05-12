#!/usr/bin/env coffee

FS = require 'fs'

words = FS.readFileSync 'google-10000-english-usa.txt'
words = "#{words}".split '\n'
dict = {}
for word, i in words
 dict[word] = i
js = "window.GOOGLE_10000_WORDS = #{JSON.stringify dict, null, 1};"
FS.writeFileSync 'assets/google_10000_words.js', js
