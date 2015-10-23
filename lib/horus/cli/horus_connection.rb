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
      headers.merge!({ "HTTP_HOST": "#{ENV['HORUS_TENANT']}.lvh.me" }) if ENV['HORUS_TENANT']
      headers
    end
  end
end
