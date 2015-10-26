module Horus
  module Cli
    module Manager
      class Base < JsonApiClient::Resource
        self.site = Horus::Cli::Config::API_BASE_URL+"api/v1/manager/"
      end
      class Client < Base
        has_many :telephones, class_name: 'ClientTelephone'
        has_one :address, class_name: 'ClientAddress'
      end
      class ClientTelephone < Base
        def self.table_name
          "client-telephones"
        end
      end
      class ClientAddress < Base
        def self.table_name
          "client-addresses"
        end
      end
      class Profile < Base
        def self.table_name
          "profile"
        end
      end
    end
  end
end
