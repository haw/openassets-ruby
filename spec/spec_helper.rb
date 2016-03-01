# $LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'rubygems'
require 'openassets'
require 'json'

RSpec.configure do |config|
  config.before(:each) do |example|
    if example.metadata[:network] == :testnet
      Bitcoin.network = :testnet3
    else
      Bitcoin.network = :bitcoin
    end
  end
end