module Horus
  module Cli
    module Admin
      class Base < JsonApiClient::Resource
        self.site = Horus::Cli::Config::API_BASE_URL+"api/v1/admin/"
      end
      class Profile < Base
        def self.table_name
          "profile"
        end
      end
    end
  end
end
