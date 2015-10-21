require "horus/cli/horus_connection"
module Horus::Cli::Manager
  class Base < JsonApiClient::Resource
    self.site = Horus::Cli::Config::API_BASE_URL+"api/v1/manager/"
  end
  class Client < Base
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
end
