require "thor"
require "json_api_client"
require "net/http"
require "horus/cli/version"
require "horus/cli/config"
require "horus/helpers"
require "horus/cli/horus_connection"
require "horus/cli/manager"
require "horus/cli/admin"
require "horus/cli/user"

module Horus
  module Cli
    class Command < Thor
      include Horus::Helpers
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

      desc 'login [--manager, --admin, --user] [--domain mydomain.com]', "Login in Horus API"
      option :manager
      option :admin
      option :user
      option :domain
      def login
        if options.length == 0
          abort("You need especify one option --admin, --manager or --user")
        end
        puts "Enter your Horus credentials."
        print "E-mail: "
        username = ask
        print "Password (typing will be hidden): "
        password = ask_for_password
        if options[:domain]
          uri = URI("http://#{options[:domain]}/oauth/token")
        else
          uri = URI(Config::API_BASE_URL+"oauth/token")
        end

        puts "Authing with #{username} in #{uri}:"
        begin
          http = Net::HTTP.new(uri.host,uri.port)
          req = Net::HTTP::Post.new(uri.path)
          req.set_form_data("grant_type" => "password", "username" => username, "password" => password)
          res = http.request(req)
          json = JSON.parse(res.body)
          ENV['HORUS_TOKEN'] = json['access_token']
          user_type = 'Manager' if options[:manager]
          user_type = 'Admin' if options[:admin]
          user_type = 'User' if options[:user]
          ENV['HORUS_USER_TYPE'] = user_type
          save_credentials
          puts "You are logged!"
        rescue => e
          puts "Login failed try again!"
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
          puts relation
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
      #def create(resource, data, relation = nil, id = nil)
        set_token
        data = "{#{data}}"
        data = eval(data)
        # if relation.nil?
        #   resource_class = get_resource_class(resource)
        #   obj = resource_class.new(data)
        # else
        #   relation_class = get_resource_class(relation)
        #   obj = relation_class.find(id).first
        #   resource_class = get_resource_class(resource)
        #   if resource == 'telephones'
        #     obj.relationships.telephones = [resource_class.new(data)]
        #   elsif resource == 'addresses'
        #     obj.relationships.address = [resource_class.new(data)]
        #   else
        #     abort("Error: RESOURCE not exist")
        #   end
        # end
        resource_class = get_resource_class(resource)
        obj = resource_class.new(data)
        if !obj.save
          abort("Error: #{obj.errors.full_messages}")
        end
        puts "Created! #{obj.attributes}"
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

      desc 'profile [show, update]', "Show user profile"
      def profile(action, data = nil)
        if(action!='show' && action!='update')
          abort("Error: please send a corrent action")
        end
        set_token
        resource_class = get_resource_class('profile')
        profile = resource_class.first
        if action == 'update' && data != nil
          data = "{#{data}}"
          data = eval(data)
          result_resource = { :data => { :type => "#{profile.attributes[:type].pluralize}",:id => "#{profile.attributes[:id]}",:attributes => data} }
          profile = resource_class.parser.parse(resource_class, resource_class.connection.run(:patch,"profile",result_resource,{}))
        end
        puts profile.inspect
      end

    end
  end
end
