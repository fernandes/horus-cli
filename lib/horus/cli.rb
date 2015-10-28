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
          url = "http://#{options[:domain]}/oauth/token"
        else
          url = Config::API_BASE_URL+"oauth/token"
        end
        user_type = 'Manager' if options[:manager]
        user_type = 'Admin' if options[:admin]
        user_type = 'User' if options[:user]
        puts "Authing with #{username} in #{url}:"
        if login_as(user_type, username, password, url)
          say "You are logged!"
        else
          say "Login failed try again!"
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
          result = ''
          results.each do |r|
            result += r.attributes.to_s
            result += "\n"
          end
        else
          result = "Results not found!"
        end
        say result
        result
      end

      desc "create RESOURCE '\"name\": \"Name\", \"email\": \"email@example.com\"", "Create a new resource"
      def create(resource, data, relation = nil, id = nil)
        set_token
        data = "{#{data}}"
        puts data
        data = eval(data)
        if relation.nil?
          resource_class = get_resource_class(resource)
          obj = resource_class.new(data)
        else
          relation_class = get_resource_class(relation)
          resource_class = get_resource_class(resource)
          obj = resource_class.new(data)
          if relation == 'clients'
            obj.relationships.client = relation_class.find(id).first
          else
            abort("Error: RESOURCE not exist")
          end
        end
        if !obj.save
          abort("Error: #{obj.errors.full_messages}")
        end
        say obj.attributes
      end

      desc "show RESOURCE id", "Show resource details"
      def show(resource, id)
        set_token
        resource_class = get_resource_class(resource)
        obj = resource_class.find(id).first
        say obj.attributes
      end

      desc 'update RESOURCE id \'"name":"Update Name", "email":"update_email@example.com"\'', "Update a resource"
      def update(resource, id, data)
        set_token
        data = "{#{data}}"
        data = eval(data)
        resource_class = get_resource_class(resource)
        obj = resource_class.find(id).first
        if !obj.update_attributes(data)
          say "Error: #{obj.errors.full_messages}"
        else
          say obj.attributes
        end
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
          profile = resource_class.parser.parse(resource_class, resource_class.connection.run(:patch,"profile",result_resource,{})).first
        end
        say profile.attributes
      end

    end
  end
end
