require 'test_helper'

class Horus::CliTest < Minitest::Test
  def test_that_it_has_a_version_number
    assert ::Horus::Cli::VERSION == "0.1.0"
  end

  def test_command_version
    out = get_command_output(['version'])
    assert out == "#{Horus::Cli::Config::COMPANY}-cli #{Horus::Cli::VERSION}\n"
  end

  def test_command_company_options
    out = get_command_output(['company_options'])
    assert out.index('company: ') != nil
    assert out.index('url: ') != nil
  end

  def test_command_show
    out = get_command_output(['show','telephones'])
    puts ENV['RACK_ENV'].inspect
    assert out.index(' show RESOURCE id') != nil
  end
end
