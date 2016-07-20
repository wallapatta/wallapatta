ELECTRON = require 'electron'
IPC = ELECTRON.ipcMain

FILTERS = [
 name: 'Wallapatta', extensions: ['ds']
]

IPC.on 'openFile', (e) ->
 ELECTRON.dialog.showOpenDialog
  properties: ['openFile']
  filters: FILTERS
  (files) ->
   e.sender.send 'fileOpened', files

IPC.on 'openFolder', (e) ->
 ELECTRON.dialog.showOpenDialog
  properties: ['openDirectory']
  (files) ->
   e.sender.send 'folderOpened', files

IPC.on 'saveFile', (e) ->
 ELECTRON.dialog.showSaveDialog
  filters: FILTERS
  (filename) ->
   e.sender.send 'saveFile', filename

IPC.on 'getUserDataPath', (e) ->
 path = ELECTRON.app.getPath 'userData'
 e.sender.send 'userDataPath', path
