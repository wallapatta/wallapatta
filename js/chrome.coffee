Mod.require 'Editor',
 (Editor) ->

  onError = (e) ->
   console.error e

  addToFileSystem = (entry, content) ->
   name = entry.name
   regex = /^data.+;base64,/
   if regex.test content
    content = content.replace regex, ""
    #imgobj = B64.decode(imgobj);
    content = window.atob content
   else
    console.log "it's already :", typeof content

   onFileSystem = (fs) ->
    fs.root.getFile name,
     create: true
     (entry) ->
      console.log entry
      entry.createWriter (writer) ->
       writer.onwriteend = (e) ->
        console.log "write complete: ", e
        console.log "size of file: ", e.total
        console.log entry.toURL()
        #document.body.innerHTML = "<img src=\"#{entry.toURL()}\">"
       writer.onerror = (e) ->
        console.log "Write failed: ", e.toString()

       data = new Blob [content], type: "image/png"
       writer.write data
      , onError
     onError

   window.webkitRequestFileSystem window.TEMPORARY, 100*1024*1024, onFileSystem, onError


  readAsText = (entry, callback) ->
   entry.file (file) ->
    document.body.innerHTML = "<img src=\"#{window.URL.createObjectURL(file)}\">"
    reader = new FileReader()

    reader.onerror = onError
    reader.onload = (e) ->
     callback e.target.result

    reader.readAsText file

  loadDirEntry = (entry) ->
   return unless entry.isDirectory
   reader = entry.createReader()

   readEntries = ->
    reader.readEntries onRead, onError

   onRead = (results) ->
    if results.length is 0
     console.log 'finished'
    else
     for e in results
      console.log e.fullPath
      do (e) ->
       readAsText e, (content) ->
        console.log 'read'
        addToFileSystem e, content
     readEntries()

   readEntries()

  chrome.fileSystem.chooseEntry type: 'openDirectory', (entry) ->
   if not entry?
    chrome.error 'No dirrectory selected'
    return

   chrome.storage.local.set
    directory: chrome.fileSystem.retainEntry entry

   loadDirEntry entry


