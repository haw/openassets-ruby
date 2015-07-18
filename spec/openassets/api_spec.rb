require 'spec_helper'

describe OpenAssets::Api do

  it 'is testnet?' do
    api = OpenAssets::Api.new
    expect(api.is_testnet?).to be false
    api = OpenAssets::Api.new(JSON.parse(File.read("#{File.dirname(__FILE__)}/../test-config.json"), {:symbolize_names => true}))
    expect(api.is_testnet?).to be true
  end

end