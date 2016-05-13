electron = require 'electron'
app = electron.app
BrowserWindow = electron.BrowserWindow
PATH = require 'path'
mainWindow = null
console.log electron

require './app'


handleSquirrelEvent = ->
 return false if process.argv.length <= 1
 return false if process.platform isnt 'win32'

 ChildProcess = require 'child_process'
 appFolder = PATH.resolve process.execPath, '..'
 rootAtomFolder = PATH.resolve appFolder, '..'
 updateDotExe = PATH.resolve PATH.join rootAtomFolder, 'Update.exe'
 exeName = PATH.basename process.execPath

 spawn = (command, args) ->
   try
    spawnedProcess = ChildProcess.spawn command, args, detached: true
   catch e
    console.log e

   return spawnedProcess

 spawnUpdate = (args) ->  spawn updateDotExe, args

 squirrelEvent = process.argv[1]
 switch squirrelEvent
  when '--squirrel-install', '--squirrel-updated'
   #Add exe to PATH, write to registry for file associations etc

   #Install desktop and start menu shortcuts
   spawnUpdate ['--createShortcut', exeName]

   setTimeout app.quit, 1000
   return true

  when '--squirrel-uninstall'
   #Undo anything you did in the --squirrel-install and
   #--squirrel-updated handlers

   #Remove desktop and start menu shortcuts
   spawnUpdate ['--removeShortcut', exeName]

   setTimeout app.quit, 1000
   return true

  when '--squirrel-obsolete'
   # This is called on the outgoing version of your app before
   # we update to the new version - it's the opposite of
   # --squirrel-updated

   app.quit()
   return true

createWindow = ->
 #console.log electron
 autoUpdater = electron.autoUpdater
 autoUpdater.setFeedURL "http://localhost:3000/update"
 mainWindow = new BrowserWindow width: 800, height: 600
 mainWindow.setMenu null
 mainWindow.loadURL "file://#{__dirname}/index.html"
 mainWindow.webContents.openDevTools()

 mainWindow.on 'closed', ->
  # Dereference the window object, usually you would store windows
  # in an array if your app supports multi windows, this is the time
  # when you should delete the corresponding element.
  mainWindow = null

 autoUpdater.addListener 'error', (e) ->
  throw 'error'

 mainWindow.webContents.once "did-frame-finish-load", (e) ->
  console.log 'frame load'
  #/update/RELEASES?id=analytics&localVersion=4.0.0&arch=amd64
  #autoUpdater.checkForUpdates()


return if handleSquirrelEvent()

app.on 'ready', createWindow

app.on 'window-all-closed', ->
 # On OS X it is common for applications and their menu bar
 # to stay active until the user quits explicitly with Cmd + Q
 if process.platform isnt 'darwin'
  app.quit()

app.on 'activate', ->
 # On OS X it's common to re-create a window in the app when the
 # dock icon is clicked and there are no other windows open.
 if not mainWindow?
  createWindow()
