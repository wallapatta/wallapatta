#!/usr/bin/env coffee

require './lib/mod/mod'

d3 = require 'd3'
Weya = require './lib/weya/weya'
Weya.Base = require './lib/weya/base'
fs = require 'fs'

Mod.set 'd3', d3
Mod.set 'Weya', Weya
Mod.set 'Weya.Base', Weya.Base

#TODO
require './coffee/xxx'

Mod.initialize()
