require 'spec_helper'
describe OpenAssets::Provider::BitcoinCoreProvider do

  it 'undefined api call' do
    provider = OpenAssets::Provider::BitcoinCoreProvider.new({})
    expect(provider).to receive(:request).with(:getinfo)
    provider.getinfo
  end

  it 'use import_address' do
    rest_client_mock = double('Rest Client')
    config = {user: 'user', password: 'password', schema: 'https', port: '8332', host: 'localhost',timeout: 60 , open_timeout: 60}
    provider = OpenAssets::Provider::BitcoinCoreProvider.new(config)
    allow(RestClient::Request).to receive(:execute).and_return(rest_client_mock)

    expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"importaddress\",\"params\":[\"address\"],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
    provider.import_address(:address)

    expect(provider).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"importaddress\",\"params\":[\"address\"],\"id\":\"jsonrpc\"}", {:content_type=>:json})
    provider.import_address(:address)

    expect(provider).to receive(:request).with("importaddress", :address)
    provider.import_address(:address)
  end

end