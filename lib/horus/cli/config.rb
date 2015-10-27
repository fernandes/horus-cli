module Horus
  module Cli
    module Config
      COMPANY = "horus"
      API_BASE_URL = "http://localhost:3000/"
      HORUS_CONFIG_PATH = ENV['HORUS_CONFIG_PATH'] || ENV['HOME']+"/.horus"
    end
  end
end
