# Vk:Auth

Crystal library for getting an [Access Token](https://vk.com/dev/access_token) without manually accessing [vk.com](https://vk.com) website from the browser.

`access_token` is needed to run most [Vk API requests](https://vk.com/dev/api_requests).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     vk_auth:
       github: mamantoha/vk_auth
   ```

2. Run `shards install`

## Usage

```crystal
require "vk_auth"
```

## Getting a Token

This library supports the [Implicit flow](https://vk.com/dev/implicit_flow_user) way to obtain an OAuth 2.0 access token.

The `Vk::Auth` constructor takes one argument - the Vk application ID.

```crystal
client = Vk::Auth.new(client_id)
```

The `#get_token` method takes the following arguments:

- `email`: user login
- `password`: user password
- `permissions`: request [application permissions](https://vk.com/dev/permissions)

```crystal
client.get_token(email, password, permissions: ["friends"])
```

After successful authorization, you can access `#access_token`:

```crystal
if client.authorized?
  client.access_token # => NamedTuple(access_token: String, expires_in: String, user_id: String)
  access_token = client.token.not_nil!["access_token"]
end
```

## API requests

> Note, this shard doesn't provide the functionality to make API requests.

You can use previously obtained `access_token` to make API requests.

For example:

```crystal
require "http/client"

access_token = "user-access-token"
method_name = "users.get"
parameters = "fields=bdate,city,country"
version = "5.131"
lang = "en"

url = "https://api.vk.com/method/#{method_name}?#{parameters}&access_token=#{access_token}&v=#{version}&lang=#{lang}"

resp = HTTP::Client.get(url)
```

## Contributing

1. Fork it (<https://github.com/mamantoha/vk_auth/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Anton Maminov](https://github.com/your-github-user) - creator and maintainer
