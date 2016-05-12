#Copyright 2014 - 2015
#Author: Varuna Jayasiri http://blog.varunajayasiri.com

FS = require 'fs'
PATH = require 'path'

rm_r = (path) ->
 try
  stat = FS.lstatSync path
 catch e
  return false

 if stat.isDirectory()
  files = FS.readdirSync path
  for file in files
   rm_r PATH.join path, file

  FS.rmdirSync path
 else
  FS.unlinkSync path

_mkdir_p = (parts) ->
 base = '/'
 create = []

 for segment in parts
  base = PATH.join base, segment
  if not FS.existsSync base
   create.push base

 for path in create
  console.log path
  FS.mkdirSync path

mkdir_p = (path) -> _mkdir_p (PATH.normalize path).split PATH.sep

cp = (src, dst) ->
 BLOCK_SIZE = 4096
 buf = new Buffer BLOCK_SIZE
 fdSrc = FS.openSync src, 'r'
 fdDst = FS.openSync dst, 'w'
 offset = 0
 remain = (FS.statSync src).size

 while remain > 0
  readSize = Math.min remain, BLOCK_SIZE
  FS.readSync fdSrc, buf, 0, readSize, offset
  FS.writeSync fdDst, buf, 0, readSize, offset
  remain -= readSize
  offset += readSize

 FS.closeSync fdSrc
 FS.closeSync fdDst

cp_r = (src, dst) ->
 stat = FS.statSync src

 if stat.isDirectory()
  if not FS.existsSync dst
   FS.mkdirSync dst
  files = FS.readdirSync src
  for file in files
   cp_r (PATH.join src, file), (PATH.join dst, file)
 else
  cp src, dst

chown_r = (path, uid, gid) ->
 stat = FS.statSync src

 if stat.isDirectory()
  files = FS.readdirSync src
  for file in files
   chown_r (PATH.join path, file), uid, gid

 FS.chownSync path, uid, gid

module.exports =
rm_r: rm_r
cp: cp
cp_r: cp_r
mkdir: FS.mkdirSync
mv: FS.renameSync
exists: FS.existsSync

