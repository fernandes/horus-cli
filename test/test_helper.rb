$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

ENV['HORUS_CONFIG_PATH'] = "/tmp/.horus"

require 'minitest/reporters'
require 'horus/cli'
require 'horus/cli/config'
require 'horus/helpers'

require 'minitest/autorun'

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

def get_command_output(command)
  capture_io{Horus::Cli::Command.start command}.join ''
end
