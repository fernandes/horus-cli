require 'test_helper'

class Horus::Cli::ConfigTest < Minitest::Test
  def test_comany
    assert ::Horus::Cli::Config::COMPANY == "horus"
  end
  def test_api_base_url
    assert ::Horus::Cli::Config::API_BASE_URL == "http://localhost:3000/"
  end
  def test_horus_config_path
    assert ::Horus::Cli::Config::HORUS_CONFIG_PATH == ENV['HOME']+"/.horus"
  end
end
