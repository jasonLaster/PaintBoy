chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
  if request is "create_extension"
    $('#color-picker').toggle()
