module RequestTshockApi
  class << self
    def get(endpoint, query_params = {})
      params = URI.encode_www_form(query_params)

      url = URI(File.join(endpoint, "?#{params}"))
      http = Net::HTTP.new(url.host, url.port)

      request = Net::HTTP::Get.new(url)
      request['Content-Type'] = 'application/json'
      request['Accept'] = 'application/json'
      http.request(request)
    end

    def server_status(api_host)
      response = get(File.join(api_host, '/v2/server/status'), { players: true })
      if response.is_a?(Net::HTTPOK)
        JSON.parse(response.body)
      else
        nil
      end
    end

    def player_names
      player_names = []
      Settings.tshock.api_hosts.each do |api_host|
        server_status = server_status(api_host)
        if server_status
          player_names += server_status['players'].map{|player| player['nickname']}
        end
      end
      player_names
    end
  end
end