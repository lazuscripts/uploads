import Widget from require "lapis.html"

path = (...)\sub(1, -20)\gsub "%.", "/" -- strip "widgets.file_input" from end of our path

add_script = (src) ->
  file = assert io.open src
  script -> raw file\read "*all"
  file\close!

class extends Widget
  content: =>
    add_script "#{path}/lib/resumable/resumable.js"
    add_script "#{path}/static/upload.js"

    label for: "file", id="file-label", "File"
    input type: "file", id: "file", name: "file", onchange: "upload();"
