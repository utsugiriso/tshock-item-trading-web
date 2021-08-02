# 使わんかったらあとで消す
module TshockApiToken
  class << self
    def api_token(tshock_api_host)
      token = Rails.cache.read(api_token_cache_key(tshock_api_host))
      token = create_api_token(tshock_api_host) if token.blank? || !test_api_token(tshock_api_host, token)
      token
    end

    private

    def api_token_cache_key(tshock_api_host)
      "api token of #{tshock_api_host}"
    end

    def create_api_token(tshock_api_host)
      response = get(File.join(tshock_api_host, '/v2/token/create'), { username: Settings.tshock.admin_username, password: Settings.tshock.admin_password })
      if response.is_a?(Net::HTTPOK)
        token = JSON.parse(response.body)['token']
        Rails.cache.write(api_token_cache_key(tshock_api_host), token)
        token
      else
        nil
      end
    end

    def test_api_token(tshock_api_host, api_token)
      response = get(File.join(tshock_api_host, '/tokentest'), { token: api_token })
      response.is_a?(Net::HTTPOK)
    end
  end
end