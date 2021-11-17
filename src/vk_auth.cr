require "log"
require "mechanize"

module Vk
  API_VERSION = "5.131"

  Log = ::Log.for(self)

  class Auth
    VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

    Log = Vk::Log.for(self)

    class Error < Exception
    end

    AUTHORIZE_URL = "https://oauth.vk.com/authorize"
    REDIRECT_URI  = "https://oauth.vk.com/blank.html"
    DISPLAY       = "mobile"
    RESPONSE_TYPE = "token"
    USER_AGENT    = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:94.0) Gecko/20100101 Firefox/94.0"

    getter token : NamedTuple(access_token: String, expires_in: String, user_id: String)? = nil

    # Implicit Flow for User Access Token
    #
    # https://vk.com/dev/implicit_flow_user
    def initialize(@client_id : String, *, @api_version = Vk::API_VERSION, @user_agent = USER_AGENT)
      @agent = Mechanize.new
      @agent.user_agent = @user_agent
    end

    def authorized?
      !@token.nil?
    end

    # Additinal parameters:
    #
    # - `permissions` - Access Permissions for User Token (https://vk.com/dev/permissions)
    # - `revoke` - Sets that permissions request should not be skipped even if a user is already authorized
    def get_token(email : String, password : String, *, permissions = [] of String, revoke = false)
      # Opening Authorization Dialog
      scope = permissions.join(',')

      default_headers = HTTP::Headers{
        "accept-language" => "en-US,en;q=0.9,uk;q=0.8,uk-UA;q=0.7,ru;q=0.6",
      }

      params = {
        "client_id"     => @client_id,
        "redirect_uri"  => REDIRECT_URI,
        "response_type" => RESPONSE_TYPE,
        "scope"         => scope,
        "v"             => @api_version,
        "display"       => DISPLAY,
      }

      params["revoke"] = "1" if revoke

      query = URI::Params.encode(params)

      url = "#{AUTHORIZE_URL}?#{query}"

      Log.debug { "Open login page: #{url}" }

      page = @agent.get(url, headers: default_headers)

      # Enter a login and a password in the dialog window
      login_form = page.forms.first
      login_form.field_with("email").value = email
      login_form.field_with("pass").value = password

      if (page = @agent.submit(login_form))
        Log.debug { "Submit login form" }

        unless page.css(".service_msg_warning").empty?
          error_message = page.css(".service_msg_warning").first.inner_text

          raise Error.new(error_message)
        end

        if page.uri.path == "/authorize"
          form = page.forms.first

          if form.fields.find { |f| f.name == "captcha_key" }
            raise Error.new("Captcha is required")
          else
            # Granting Access Permissions
            Log.debug { "Submit grant permissions form" }

            if (grant_permissions_page = @agent.submit(form))
              page = grant_permissions_page
            end
          end
        end

        uri = page.uri

        # Receiving access_token.
        if uri.path == "/auth_redirect" && (query_params = uri.query_params)
          authorize_url = query_params["authorize_url"]
          access_url = URI.decode(authorize_url)
          access_uri = URI.parse(access_url)

          if (fragment = access_uri.fragment)
            params = URI::Params.parse(fragment)

            @token = NamedTuple.new(
              access_token: params["access_token"],
              expires_in: params["expires_in"],
              user_id: params["user_id"]
            )
          end
        end
      end
    end
  end
end
