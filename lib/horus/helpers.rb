# encoding: utf-8

module Horus
  module Helpers
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
      resource_class = case resource
      when 'clients' then "Horus::Cli::#{ENV['HORUS_USER_TYPE']}::Client".constantize if ENV['HORUS_USER_TYPE'] == 'Manager'
      when 'telephones' then "Horus::Cli::#{ENV['HORUS_USER_TYPE']}::ClientTelephone".constantize if ENV['HORUS_USER_TYPE'] == 'Manager'
      when 'addresses' then "Horus::Cli::#{ENV['HORUS_USER_TYPE']}::ClientAddress".constantize if ENV['HORUS_USER_TYPE'] == 'Manager'
      when 'profile' then "Horus::Cli::#{ENV['HORUS_USER_TYPE']}::Profile".constantize
      else nil
      end

      if resource_class.nil?
        abort("RESOURCE not found for #{ENV['HORUS_USER_TYPE']}")
      end
      resource_class
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
        content = File.read("#{Horus::Cli::Config::HORUS_CONFIG_PATH}/credentials")
        credentials = content.split(':')
        ENV['HORUS_USER_TYPE'] = credentials[1]
        credentials[0]
      rescue => e
        puts "Error: Credentials not found!"
        false
      end
    end

    def save_credentials
      path = Horus::Cli::Config::HORUS_CONFIG_PATH
      file = "#{path}/credentials"
      if !File.directory?(path)
        FileUtils.mkdir_p(path)
      end

      if !File.exists?(file)
        FileUtils.touch(file)
      end

      File.write(file, ENV['HORUS_TOKEN']+":"+ENV['HORUS_USER_TYPE'])
    end

    def set_token
      if !ENV['HORUS_TOKEN']
        token = read_credentials
        if token
          ENV['HORUS_TOKEN'] = token
        else
          abort("You need a token! Please type: #{Horus::Cli::Config::COMPANY}-cli login.")
        end
      end
      ENV['HORUS_TOKEN']
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
