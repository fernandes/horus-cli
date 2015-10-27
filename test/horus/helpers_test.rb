require 'test_helper'

class Horus::HelpersTest < Minitest::Test
  include Horus::Helpers
  def test_get_resource_class
    ENV['HORUS_USER_TYPE'] = 'Manager'
    resource_class = get_resource_class('clients')
    assert resource_class = Horus::Cli::Manager::Client
  end
end
