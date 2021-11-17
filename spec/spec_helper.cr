require "spec"
require "vcr"
require "../src/vk_auth"

VCR.configure do |settings|
  settings.filter_sensitive_data["client_id"] = "123456"
  settings.filter_sensitive_data["email"] = "user@example.com"
  settings.filter_sensitive_data["pass"] = "password"
end
