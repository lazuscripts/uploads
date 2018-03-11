md5 = require "md5"
logging = require "lapis.logging"
resty_upload = require "resty.upload"

locate = require("locator")(...)
import validate_signature from locate "signatures" -- TODO may be moved elsewhere
import quote, execute from locate "shell"
import size from locate "fs"

import Uploads from require "models"
import to_json, parse_content_disposition from require "lapis.util"
import open from io

handler = ->
  params = ngx.req.get_uri_args!
  return nil, "no signature" unless params.signature
  return nil, "invalid signature" unless validate_signature ngx.var.uri, params.signature

  upload = Uploads\find id: ngx.var.upload_id
  return nil, "already uploaded" if upload.complete

  input, err = resty_upload\new 8192
  return nil, err unless input
  input\set_timeout 1000             -- 1 second

  tmp_path = "uploads/#{upload.id}"
  file = assert open tmp_path, "w"
  file_md5 = md5.new!
  current = {}

  _, err = pcall ->
    while true
      t, result, err = input\read!
      switch t
        when "body"
          if current.name == "file"
            assert(file, "file already closed")\write res
            file_md5\update res
        when "header"
          -- NOTE I don't understand this
          name, value = unpack res
          if name == "Content-Disposition"
            if params = parse_content_disposition value
              for tuple in *params
                current[tuple[1]] = tuple[2]
          else
            current[name\lower!] = value
        when "part_end"
          if current.name == "file"
            equal_size = upload.file_size == size file
            file\close!
            file = nil
            unless equal_size
              return nil, "file uploaded does not match expected file size"
          current = {}
        when "eof"
          break
        else
          return nil, err or "failed to read from uploaded file"

  if file
    file\close!
    return nil, "failed to upload file: #{err}"

  file_md5\finish!
  md5_sum = md5.sumhexa file_md5
  file_path = "uploads/#{md5_sum\sub 1, 2}/#{md5_sum\sub 3, 4}/#{md5_sum}/#{upload.file_name}"
  dir = file_path\match "^(.+)/[^/]+$"
  exit_code, output = execute "mkdir -p #{quote dir}"
  return nil, output if exit_code != 0
  exit_code, output = execute "mv #{quote tmp_path} #{quote file_path}"
  return nil, output if exit_code != 0

  upload\update {
    complete: true
    md5: md5_sum -- doesn't check for collisions, this uploader can be abused
    :file_path
  }

  ngx.header["Content-Type"] = "application/json"
  ngx.print to_json { success: true }

  logging.request {
    req: {
      cmd_mth: ngx.var.request_method
      cmd_url: ngx.var.uri
    }
    res: { status: 200 }
  }

  return true


-- now actually run the above ...
success, err = handle_upload!

unless success
  ngx.header["Content-Type"] = "application/json"
  ngx.print to_json { errors: {err} }
