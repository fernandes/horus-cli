module Horus
  module Cli
    module User
      class Base < JsonApiClient::Resource
        self.site = Horus::Cli::Config::API_BASE_URL+"api/v1/"
      end
      class Profile < Base
        def self.table_name
          "profile"
        end
      end
    end
  end
end
