require 'spec_helper'
describe OpenAssets::Provider::BitcoinCoreProvider do

  context 'implicitly defined methods' do
    it 'use getbalance' do
      provider = OpenAssets::Provider::BitcoinCoreProvider.new({})
      expect(provider).to receive(:request).with(:getbalance)
      provider.getbalance
    end

    it 'implicitly defined' do
      help_commands = File.read("#{File.dirname(__FILE__)}/../../help-result.txt").split("\n").inject([]) do |commands, line|
        if !line.empty? && !line.start_with?('==')
          commands << line.split(' ').first.to_sym
        end
        commands
      end
      expect(OpenAssets::Provider::BitcoinCoreProvider.public_instance_methods).to include *help_commands
    end
  end

  context 'explicitly defined methods' do
    let(:rest_client_mock) do
      rest_client_mock = double('Rest Client')
      allow(RestClient::Request).to receive(:execute).and_return(rest_client_mock)
      rest_client_mock
    end

    let(:provider) do
      config = {user: 'user', password: 'password', schema: 'https', port: '8332', host: 'localhost',timeout: 60 , open_timeout: 60}
      OpenAssets::Provider::BitcoinCoreProvider.new(config)
    end

    it 'use import_address' do
      expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"importaddress\",\"params\":[\"address\"],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
      provider.import_address(:address)

      expect(provider).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"importaddress\",\"params\":[\"address\"],\"id\":\"jsonrpc\"}", {:content_type=>:json})
      provider.import_address(:address)

      expect(provider).to receive(:request).with(:importaddress, :address)
      provider.import_address(:address)
    end

    it 'use list_unspent' do
      expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"listunspent\",\"params\":[1,9999999,[]],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
      provider.list_unspent

      expect(provider).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"listunspent\",\"params\":[1,9999999,[]],\"id\":\"jsonrpc\"}", {:content_type=>:json})
      provider.list_unspent

      expect(provider).to receive(:request).with(:listunspent, 1, 9999999, [])
      provider.list_unspent
    end

    it 'use get_transaction' do
      expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"getrawtransaction\",\"params\":[\"transaction_hash\",0],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
      provider.get_transaction(:transaction_hash)

      expect(provider).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"getrawtransaction\",\"params\":[\"transaction_hash\",0],\"id\":\"jsonrpc\"}", {:content_type=>:json})
      provider.get_transaction(:transaction_hash)

      expect(provider).to receive(:request).with(:getrawtransaction, :transaction_hash, 0)
      provider.get_transaction(:transaction_hash)
    end

    it 'use sign_transaction' do
      allow(rest_client_mock).to receive(:[]).and_return(true, '01000000000000000000')

      expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"signrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
      provider.sign_transaction(:tx)

      expect(provider).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"signrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", {:content_type=>:json}).and_return(rest_client_mock)
      provider.sign_transaction(:tx)

      expect(provider).to receive(:request).with(:signrawtransaction, :tx).and_return(rest_client_mock)
      provider.sign_transaction(:tx)
    end

    it 'use send_transaction' do
      expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"sendrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
      provider.send_transaction(:tx)

      expect(provider).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"sendrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", {:content_type=>:json})
      provider.send_transaction(:tx)

      expect(provider).to receive(:request).with(:sendrawtransaction, :tx)
      provider.send_transaction(:tx)
    end
  end

end