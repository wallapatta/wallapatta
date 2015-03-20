chrome.app.runtime.onLaunched.addListener(function(launchData) {
  chrome.app.window.create('index.html', {bounds: {width: 1200, height: 800}}, function(win) {
    win.contentWindow.launchData = launchData;
  });
});
