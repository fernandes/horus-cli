module JsonApiClient
  class Connection
    def run(request_method, path, params = {}, headers = {})
      headers = set_headers(headers)
      faraday.send(request_method, path, params, headers)
    end
    def set_headers(headers = {}, tenant = nil)
      token = ENV['HORUS_TOKEN']
      headers.merge!({"Authorization": "Bearer #{token}" })
      return headers if tenant.nil?
      headers.merge!({ "HTTP_HOST": "acme.lvh.me" }) if tenant == :acme
      headers.merge!({ "HTTP_HOST": "smart.lvh.me" }) if tenant == :smart
      headers
    end
  end
end
