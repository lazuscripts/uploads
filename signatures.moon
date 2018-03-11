-- TODO consider having the model handle signing so I don't have to worry about locator selecting correct signatures file
config = require("lapis.config").get!
import encode_base64, hmac_sha1 from require "lapis.util.encoding"

sign = (uri) ->
  signature = encode_base64 hmac_sha1 config.secret, uri
  return "#{uri}&signature=#{signature}"

validate_signature = (uri, signature) ->
  uri = uri\sub 1, uri\len! - uri\match("&signature=.+$") - 1
  return signature == sign uri

{
  :sign
  :validate_signature
}
