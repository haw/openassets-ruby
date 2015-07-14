# $LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'rubygems'
require 'openassets'
require 'json'

# load test configuration
OpenAssets.config.update(JSON.parse(File.read("#{File.dirname(__FILE__)}//test-config.json"), {:symbolize_names => true}))