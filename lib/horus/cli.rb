require "thor"
require "json_api_client"
require "net/http"
require "horus/cli/version"
require "horus/cli/config"
require "horus/cli/helpers"
require "horus/cli/horus_connection"
require "horus/cli/manager"

module Horus
  module Cli
    class Command < Thor
      desc 'version', "Display  #{Config::COMPANY}-cli version"
      map %w[-v --version] => :version
      def version
        say "#{Config::COMPANY}-cli #{VERSION}"
      end

      desc 'company_options', "Display options #{Config::COMPANY}-cli"
      map %w[-o --options] => :company_options
      def company_options
        options = "company: #{Config::COMPANY}\n"
        options += "API base url: #{Config::API_BASE_URL}\n"
        say options
      end

      desc 'login', "Login in Horus API"
      def login
        puts "Enter your Horus credentials."
        print "E-mail: "
        username = ask
        print "Password (typing will be hidden): "
        password = ask_for_password
        uri = URI(Config::API_BASE_URL+"oauth/token")
        puts "Authing with #{username} in #{uri}:"
        begin
          res = Net::HTTP.post_form(uri,"grant_type"=>"password", "username"=> username, "password"=>password)
          json = JSON.parse(res.body)
          ENV['HORUS_TOKEN'] = json['access_token']
          save_credentials
          puts "You are logged!"
        rescue => e
          puts "Login failed try again!"
          puts e
        end
      end

      desc 'list RESOURCE', "List RESOURCES to user"
      def list(resource, relation=nil)
        set_token
        resource_class = get_resource_class(resource)
        if relation.nil?
          begin
            results = resource_class.all
          rescue => e
            abort("Error: #{e} \nPlease use #{Config::COMPANY}-cli list RESOURCE 'relation_id: x'")
          end
        else
          relation = eval("{#{relation}}")
          begin
            results = resource_class.where(relation)
          rescue => e
            abort("Error: #{e}")
          end
        end
        if !results.nil? && results.length > 0
          results.each do |r|
            puts r.inspect
            puts "======================="
          end
        else
          puts "Results not found!"
        end
      end

      desc "create RESOURCE ':name => 'Name', :email => 'email@example.com'", "Create a new resource"
      def create(resource, data)
        set_token
        data = "{#{data}}"
        data = eval(data)
        resource_class = get_resource_class(resource)
        obj = resource_class.new(data)
        if !obj.save
          abort("Error: \n#{obj.errors.full_messages}")
        end
        puts "Created!\n#{obj.attributes}"
      end

      desc 'update', "Update a resource"
      def update(resource, id, data)
        set_token
        data = "{#{data}}"
        data = eval(data)
        resource_class = get_resource_class(resource)
        obj = resource_class.find(id).first
        if !obj.update_attributes(data)
          abort("Error: \n#{obj.errors.full_messages}")
        end
        puts "Updated!\n#{obj.attributes}"
      end

      no_commands do
        def ask_for_password
          begin
            echo_off
            password = ask
            puts
          ensure
            echo_on
          end
          return password
        end

        def ask
          $stdin.gets.to_s.strip
        end

        def get_resource_class(resource)
          case resource
          when 'clients' then Horus::Cli::Manager::Client
          when 'telephones' then Horus::Cli::Manager::ClientTelephone
          when 'addresses' then Horus::Cli::Manager::ClientAddress
          else abort("RESOURCE not found!")
          end
        end

        def echo_off
          with_tty do
            system "stty -echo"
          end
        end

        def echo_on
          with_tty do
            system "stty echo"
          end
        end

        def read_credentials
          begin
            File.read("#{Config::HORUS_CONFIG_PATH}/credentials")
          rescue => e
            puts "Error: Credentials not found!"
            false
          end
        end

        def save_credentials
          path = Config::HORUS_CONFIG_PATH
          file = "#{path}/credentials"
          if !File.directory?(path)
            FileUtils.mkdir_p(path)
          end

          if !File.exists?(file)
            FileUtils.touch(file)
          end

          File.write(file, ENV['HORUS_TOKEN'])
        end

        def set_token
          if !ENV['HORUS_TOKEN']
            token = read_credentials
            if token
              ENV['HORUS_TOKEN'] = token
            else
              abort("You need a token! Please type: #{Config::COMPANY}-cli login.")
            end
          end
        end

        def with_tty(&block)
          return unless $stdin.isatty
          begin
            yield
          rescue
            # fails on windows
          end
        end
      end

    end
  end
end
