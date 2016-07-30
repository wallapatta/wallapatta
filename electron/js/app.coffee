ELECTRON = require 'electron'
IPC = ELECTRON.ipcMain

FILTERS = [
 name: 'Wallapatta', extensions: ['ds']
]

IPC.on 'saveFile', (e) ->
 ELECTRON.dialog.showSaveDialog
  filters: FILTERS
  (filename) ->
   e.sender.send 'saveFile', filename

IPC.on 'getUserDataPath', (e) ->
 path = ELECTRON.app.getPath 'userData'
 e.sender.send 'userDataPath', path
