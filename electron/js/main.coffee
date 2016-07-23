electron = require 'electron'
app = electron.app
BrowserWindow = electron.BrowserWindow
PATH = require 'path'
HTTPS = require 'https'
mainWindow = null

require './app'
SLACK_OPTIONS = require './slack'
UPDATE_URL = switch process.platform
 when 'win32' then "/downloads/wallapatta/update/win32/"
 when 'darwin' then "/downloads/wallapatta/update/darwin/?version=#{app.getVersion()}"
 else "/downloads/wallapatta/update/win32/"
UPDATE_URL = "https://www.forestpin.com#{UPDATE_URL}"

REPORT = (options) ->
 attachment =
  fallback: "#{options.type}_#{options.name}: #{options.message}"
  pretext: "#{options.name}: #{options.message}"
  color: 'danger'
  fields: []

 for k, v of options
  continue if k is 'name'
  continue if k is 'message'
  v = "#{v}"
  attachment.fields.push
   title: k
   value: v
   short: v.length < 10

 data = JSON.stringify
  attachments: [attachment]
 opt = SLACK_OPTIONS()
 opt.headers['Content-Length'] = Buffer.byteLength data

 req = HTTPS.request opt, (res) ->
  status = parseInt res.statusCode
  if status isnt 200
   console.log "Error reporting: #{res.statusCode}"
   console.log res.headers
   req.on 'data', (data) ->
    console.log data
   req.on 'end', ->
    console.log 'End'

 req.on 'error', (e) ->
  console.log "Error reporting: #{e.message}"
 req.write data
 req.end()


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
    REPORT
     type: 'Wallapatta'
     name: 'SpawnError'
     message: e.message
     platform: process.platform
     command: command
    spawnedProcess = null

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
 autoUpdater = electron.autoUpdater
 try
  autoUpdater.setFeedURL UPDATE_URL
 catch e
  autoUpdater = null
  REPORT
   type: 'Wallapatta'
   name: 'AutoUpdateError'
   message: e.message
   platform: process.platform

 mainWindow = new BrowserWindow width: 1200, height: 900
 #mainWindow.setMenu null
 mainWindow.loadURL "file://#{__dirname}/index.html"
 #mainWindow.webContents.openDevTools()

 mainWindow.on 'closed', ->
  # Dereference the window object, usually you would store windows
  # in an array if your app supports multi windows, this is the time
  # when you should delete the corresponding element.
  mainWindow = null

 if autoUpdater?
  autoUpdater.addListener 'error', (e) ->
   REPORT
    type: 'Wallapatta'
    name: 'AutoUpdateError'
    message: e.message
    platform: process.platform

 mainWindow.webContents.once "did-frame-finish-load", (e) ->
  if autoUpdater?
   autoUpdater.checkForUpdates()


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
