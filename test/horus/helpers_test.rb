require 'test_helper'
require 'securerandom'

class Horus::HelpersTest < Minitest::Test
  include Horus::Helpers

  def teardown
    echo_on
  end
  
  def test_get_resource_class
    ENV['HORUS_USER_TYPE'] = 'Manager'
    resource_class = get_resource_class('clients')
    assert resource_class == Horus::Cli::Manager::Client
  end

  def test_login_as_manager
    logged = login_as('Manager', 'manager@example.com', 'pass1234', Horus::Cli::Config::API_BASE_URL+"oauth/token")
    assert logged == true
  end

  def test_login_as_admin
    logged = login_as('Admin', 'admin@smart.com', 'pass1234', 'http://smart.lvh.me:3000/oauth/token')
    assert logged == true, "Failed to login as Admin"
  end

  def test_login_as_user
    logged = login_as('User', 'user@smart.com', 'pass1234', 'http://smart.lvh.me:3000/oauth/token')
    assert logged == true, "Failed to login as User"
  end

  def test_read_credentials
    ENV['HORUS_TOKEN'] = SecureRandom.hex
    ENV['HORUS_USER_TYPE'] = 'Admin'
    save_credentials
    assert read_credentials == ENV['HORUS_TOKEN']
    File.delete("#{Horus::Cli::Config::HORUS_CONFIG_PATH}/credentials")
    assert read_credentials == false
  end

  def test_save_credentials
    ENV['HORUS_TOKEN'] = SecureRandom.hex
    ENV['HORUS_USER_TYPE'] = 'Admin'
    letters_count = "#{ENV['HORUS_TOKEN']}:#{ENV['HORUS_USER_TYPE']}".length
    assert save_credentials == letters_count
  end

  def test_set_token
    token = SecureRandom.hex
    ENV['HORUS_TOKEN'] = token
    assert set_token == token
  end

  def test_echo_on
    assert echo_off == true
  end

  def test_echo_off
    assert echo_on == true
  end

  def test_ask_for_password
    assert ask_for_password == 'mypassword'
  end

  def ask
    'mypassword'
  end
end
