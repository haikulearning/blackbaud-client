require 'bundler/setup'
Bundler.setup

require 'blackbaud-client'
require 'webmock/rspec'
require 'pry'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
end