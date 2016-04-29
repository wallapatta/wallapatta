#!/usr/bin/env coffee

FS = require 'fs'

words = FS.readFileSync 'google-10000-english-usa.txt'
words = "#{words}".split '\n'
js = "window.GOOGLE_1000_WORDS = #{JSON.stringify words, null, 1};"
FS.writeFileSync 'assets/google_10000_words.js', js
