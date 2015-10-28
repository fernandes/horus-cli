module JsonApiClient
  class Connection
    def run(request_method, path, params = {}, headers = {})
      headers = set_headers(headers)
      faraday.send(request_method, path, params, headers)
    end
    def set_headers(headers = {})
      token = ENV['HORUS_TOKEN']
      headers.merge!({"Authorization": "Bearer #{token}" })
      headers
    end
  end
end
