# This file is used by Rack-based servers to start the application.

Thread.new {
  EM.run do
    puts "=> EventMachine started"
  end
} unless defined?(Thin)

require ::File.expand_path('../lib/monitorer',  __FILE__)
require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application.class