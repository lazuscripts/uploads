locate = require("locator")(...)
import validate_signature from locate "signatures" -- TODO may be moved elsewhere

params = ngx.req.get_uri_args!
unless params.signature
  return ngx.exit ngx.HTTP_FORBIDDEN
unless validate_signature ngx.var.uri, params.signature
  return ngx.exit ngx.HTTP_FORBIDDEN

if ngx.now! > tonumber params.expires
  return ngx.exit ngx.HTTP_GONE

import Uploads from require "models"

upload = Uploads\find id: ngx.var.uri\match "/download/.-(%d+)"
file = upload.file_path\gsub '"', "\\%1"

ngx.header.content_disposition = "attachment; filename=\"#{file}\""
ngx.header.content_transfer_encoding = "binary"
