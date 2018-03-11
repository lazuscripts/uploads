lapis = require "lapis"

import Uploads from require "models"
import respond_to, capture_errors, assert_error, yield_error from require "lapis.application"
import assert_valid from require "lapis.validate"
import autoload from require "locator"
import settings from autoload "utility"

gb = 1024*1024*1024
mb = 1024*1024
kb = 1024

friendly_size = (bytes) ->
  if bytes >= gb
    return "#{format "%.2f", bytes / gb} GB"
  elseif bytes >= mb
    return "#{format "%.2f", bytes / mb} MB"
  elseif bytes >= kb
    return "#{format "%.2f", bytes / kb} KB"
  else
    return "#{bytes} bytes"

class extends lapis.Application
  @path: "/upload"
  @name: "file_"

  [prepare: "/prepare"]: respond_to {
    POST: capture_errors {
      on_error: =>
        return status: 500, json: { errors: @errors }

      =>
        @params.file_size = tonumber @params.file_size
        assert_valid @params, {
          {"file_name", exists: true, "File name was not sent."}
          {"file_size", exists: true, "File size was not sent."}
          {"file_size", is_integer: true, "File size is not an integer."}
        }

        file_name = @params.file_name
        file_extension = file_name\match("^.+%.(.+)$") or file_name
        file_size = @params.file_size

        if file_size > settings["uploads.max_file_size"]
          yield_error "File too large. Max file size: #{friendly_size settings["uploads.max_file_size"]}. Your file's size: #{friendly_size file_size}."

        upload = assert_error Uploads\create {
          :file_name
          :file_extension
          :file_size
        }

        return json: { success: true, uri: sign @url_for "file_upload", {id: upload.id}, {expires: false} }
    }
  }

  [upload: "/:id"]: =>
    error "Placeholder."
