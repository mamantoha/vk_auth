require "./spec_helper"

describe Vk::Auth do
  it "get token" do
    client_id = ENV["CLIENT_ID"]

    email = ENV["EMAIL"]
    password = ENV["PASSWORD"]
    permissions = ["friends"]

    client = Vk::Auth.new(client_id)

    load_cassette("get-token") do
      client.get_token(email, password, permissions: permissions)

      client.authorized?.should be_true
      client.token.should_not be_nil
    end
  end
end
