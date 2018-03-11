import create_table, types from require "lapis.db.schema"
import autoload from require "locator"
import settings from autoload "utility"

{
  [1520225374]: =>
    create_table "uploads", {
      {"id", types.serial primary_key: true}
      {"md5", types.varchar null: true}    -- created when file is uploaded
      {"file_name", types.text}            -- created BEFORE upload
      {"file_path", types.text null: true} -- created when file is uploaded
      {"file_extension", types.text}       -- created BEFORE upload
      {"file_size", types.integer}         -- created BEFORE upload (then verified)
      {"complete", types.boolean default: false}

      {"created_at", types.time}
      {"updated_at", types.time}
    }
    settings.set "uploads.max_file_size", 100*1024*1024 -- 100 MB default
}
