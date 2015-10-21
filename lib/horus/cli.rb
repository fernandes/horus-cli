require "horus/cli/version"
require "horus/cli/config"
require "horus/cli/helpers"
require "thor"
require "json_api_client"
require "horus/cli/manager/base"
require 'net/http'

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

      desc 'list RESOURCE', "List RESOURCES to user"
      def list(resource, token = nil)
        if resource == 'clients'
          resource_class = Horus::Cli::Manager::Client
        elsif resource == 'telephones'
          resource_class = Horus::Cli::Manager::ClientTelephone
        elsif resource == 'addresses'
          resource_class = Horus::Cli::Manager::ClientAddress
        else
          abort("RESOURCE not found!")
        end
        if !ENV['HORUS_TOKEN'] && token.nil?
          token = read_credentials
          if token
            ENV['HORUS_TOKEN'] = token
            results = resource_class.all
            results.each do |r|
              puts r.inspect
            end
          else
            puts "You need a token! Please type: #{Config::COMPANY}-cli login."
          end
        end
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

      no_commands do
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

        def with_tty(&block)
          return unless $stdin.isatty
          begin
            yield
          rescue
            # fails on windows
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

        def read_credentials
          begin
            File.read("#{Config::HORUS_CONFIG_PATH}/credentials")
          rescue => e
            puts "Error: Credentials not found!"
            false
          end
        end
      end

    end
  end
end
