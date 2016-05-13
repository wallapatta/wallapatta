ELECTRON = require 'electron'
IPC = ELECTRON.ipcMain

console.log ELECTRON.app.getPath 'userData'

IPC.on 'openFile', (e) ->
 ELECTRON.dialog.showOpenDialog properties: ['openFile'], (files) ->
  e.sender.send 'fileOpened', files

IPC.on 'getUserDataPath', (e) ->
 path = ELECTRON.app.getPath 'userData'
 e.sender.send 'userDataPath', path
