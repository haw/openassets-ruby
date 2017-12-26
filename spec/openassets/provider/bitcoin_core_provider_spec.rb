require 'spec_helper'
describe OpenAssets::Provider::BitcoinCoreProvider do

  describe 'implicitly defined method#getbalance' do
    context 'use new provider.getbalance' do
      it 'returns provider.getbalance' do
        provider = OpenAssets::Provider::BitcoinCoreProvider.new({})
        expect(provider).to receive(:request).with(:getbalance)
        provider.getbalance
      end
    end
  end

  describe 'implicitly defined methods' do
    context 'implicitly defined' do
      it 'returns help results' do
        help_commands = File.read("#{File.dirname(__FILE__)}/../../help-result.txt").split("\n").inject([]) do |commands, line|
          if !line.empty? && !line.start_with?('==')
            commands << line.split(' ').first.to_sym
          end
          commands
        end
        expect(OpenAssets::Provider::BitcoinCoreProvider.public_instance_methods).to include *help_commands
      end
    end
  end

  describe 'explicitly defined methods' do

    let(:rest_client_mock) do
      rest_client_mock = double('Rest Client')
      allow(RestClient::Request).to receive(:execute).and_return(rest_client_mock)
      rest_client_mock
    end

    # For node-level RPC
    let(:provider_node_level) do
      config = {schema: 'https', user: 'user', password: 'password', host: 'localhost', port: '8332', wallet: '', timeout: 60, open_timeout: 60}
      OpenAssets::Provider::BitcoinCoreProvider.new(config)
    end

    # For node-level RPC (backward compatible: missing 'wallet' in config)
    let(:provider_node_level_backward) do
      config = {schema: 'https', user: 'user', password: 'password', host: 'localhost', port: '8332', timeout: 60, open_timeout: 60}
      OpenAssets::Provider::BitcoinCoreProvider.new(config)
    end

    # For wallet-level RPC
    let(:provider_wallet_level) do
      config = {schema: 'https', user: 'user', password: 'password', host: 'localhost', port: '8332', wallet: 'wallet.dat', timeout: 60, open_timeout: 60}
      OpenAssets::Provider::BitcoinCoreProvider.new(config)
    end

    context '#importaddress' do
      context 'use node-level importaddress' do
        it 'returns node-level importaddress' do
          expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"importaddress\",\"params\":[\"address\"],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
          provider_node_level.import_address(:address)

          expect(provider_node_level).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"importaddress\",\"params\":[\"address\"],\"id\":\"jsonrpc\"}", {:content_type=>:json})
          provider_node_level.import_address(:address)

          expect(provider_node_level).to receive(:request).with(:importaddress, :address)
          provider_node_level.import_address(:address)
        end
      end

      context 'use node-level importaddress with backward compatibility' do
        it 'returns node-level importaddress' do
          expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"importaddress\",\"params\":[\"address\"],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
          provider_node_level_backward.import_address(:address)

          expect(provider_node_level_backward).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"importaddress\",\"params\":[\"address\"],\"id\":\"jsonrpc\"}", {:content_type=>:json})
          provider_node_level_backward.import_address(:address)

          expect(provider_node_level_backward).to receive(:request).with(:importaddress, :address)
          provider_node_level_backward.import_address(:address)
        end
      end

      context 'use wallet-level importaddress' do
        it 'returns wallet-level importaddress' do
          expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332/wallet/wallet.dat", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"importaddress\",\"params\":[\"address\"],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
          provider_wallet_level.import_address(:address)

          expect(provider_wallet_level).to receive(:post).with("https://user:password@localhost:8332/wallet/wallet.dat", 60, 60, "{\"method\":\"importaddress\",\"params\":[\"address\"],\"id\":\"jsonrpc\"}", {:content_type=>:json})
          provider_wallet_level.import_address(:address)

          expect(provider_wallet_level).to receive(:request).with(:importaddress, :address)
          provider_wallet_level.import_address(:address)
        end
      end
    end

    context '#list_unspent' do
      context 'use node-level list_unspent' do
        it 'returns node-level list_unspent' do
          expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"listunspent\",\"params\":[1,9999999,[]],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
          provider_node_level.list_unspent
    
          expect(provider_node_level).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"listunspent\",\"params\":[1,9999999,[]],\"id\":\"jsonrpc\"}", {:content_type=>:json})
          provider_node_level.list_unspent
    
          expect(provider_node_level).to receive(:request).with(:listunspent, 1, 9999999, [])
          provider_node_level.list_unspent
        end
      end

      context 'use node-level list_unspent with backward compatibility' do
        it 'returns node-level list_unspent' do
          expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"listunspent\",\"params\":[1,9999999,[]],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
          provider_node_level_backward.list_unspent
    
          expect(provider_node_level_backward).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"listunspent\",\"params\":[1,9999999,[]],\"id\":\"jsonrpc\"}", {:content_type=>:json})
          provider_node_level_backward.list_unspent
    
          expect(provider_node_level_backward).to receive(:request).with(:listunspent, 1, 9999999, [])
          provider_node_level_backward.list_unspent
        end
      end

      context 'use wallet-level list_unspent' do
        it 'returns wallet-level list_unspent' do
          expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332/wallet/wallet.dat", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"listunspent\",\"params\":[1,9999999,[]],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
          provider_wallet_level.list_unspent
    
          expect(provider_wallet_level).to receive(:post).with("https://user:password@localhost:8332/wallet/wallet.dat", 60, 60, "{\"method\":\"listunspent\",\"params\":[1,9999999,[]],\"id\":\"jsonrpc\"}", {:content_type=>:json})
          provider_wallet_level.list_unspent
    
          expect(provider_wallet_level).to receive(:request).with(:listunspent, 1, 9999999, [])
          provider_wallet_level.list_unspent
        end
      end
    end

    context '#get_transaction' do
      context 'use node-level get_transaction' do
        it 'returns node-level get_transaction' do
          expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"getrawtransaction\",\"params\":[\"transaction_hash\",0],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
          provider_node_level.get_transaction(:transaction_hash)
    
          expect(provider_node_level).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"getrawtransaction\",\"params\":[\"transaction_hash\",0],\"id\":\"jsonrpc\"}", {:content_type=>:json})
          provider_node_level.get_transaction(:transaction_hash)
    
          expect(provider_node_level).to receive(:request).with(:getrawtransaction, :transaction_hash, 0)
          provider_node_level.get_transaction(:transaction_hash)
        end
      end

      context 'use node-level get_transaction with backward compatibility' do
        it 'returns node-level get_transaction' do
          expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"getrawtransaction\",\"params\":[\"transaction_hash\",0],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
          provider_node_level_backward.get_transaction(:transaction_hash)
    
          expect(provider_node_level_backward).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"getrawtransaction\",\"params\":[\"transaction_hash\",0],\"id\":\"jsonrpc\"}", {:content_type=>:json})
          provider_node_level_backward.get_transaction(:transaction_hash)
    
          expect(provider_node_level_backward).to receive(:request).with(:getrawtransaction, :transaction_hash, 0)
          provider_node_level_backward.get_transaction(:transaction_hash)
        end
      end

      context 'use wallet-level get_transaction' do
        it 'returns wallet-level get_transaction' do
          expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332/wallet/wallet.dat", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"getrawtransaction\",\"params\":[\"transaction_hash\",0],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
          provider_wallet_level.get_transaction(:transaction_hash)
    
          expect(provider_wallet_level).to receive(:post).with("https://user:password@localhost:8332/wallet/wallet.dat", 60, 60, "{\"method\":\"getrawtransaction\",\"params\":[\"transaction_hash\",0],\"id\":\"jsonrpc\"}", {:content_type=>:json})
          provider_wallet_level.get_transaction(:transaction_hash)
    
          expect(provider_wallet_level).to receive(:request).with(:getrawtransaction, :transaction_hash, 0)
          provider_wallet_level.get_transaction(:transaction_hash)
        end
      end
    end

    context '#sign_transaction' do
      context 'use node-level sign_transaction' do
        it 'returns node-level sign_transaction' do
          allow(rest_client_mock).to receive(:[]).and_return(true, '01000000000000000000')

          expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"signrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
          provider_node_level.sign_transaction(:tx)
    
          expect(provider_node_level).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"signrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", {:content_type=>:json}).and_return(rest_client_mock)
          provider_node_level.sign_transaction(:tx)
    
          expect(provider_node_level).to receive(:request).with(:signrawtransaction, :tx).and_return(rest_client_mock)
          provider_node_level.sign_transaction(:tx)
        end
      end

      context 'use node-level sign_transaction with backward compatibility' do
        it 'returns node-level sign_transaction' do
          allow(rest_client_mock).to receive(:[]).and_return(true, '01000000000000000000')

          expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"signrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
          provider_node_level_backward.sign_transaction(:tx)
    
          expect(provider_node_level_backward).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"signrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", {:content_type=>:json}).and_return(rest_client_mock)
          provider_node_level_backward.sign_transaction(:tx)
    
          expect(provider_node_level_backward).to receive(:request).with(:signrawtransaction, :tx).and_return(rest_client_mock)
          provider_node_level_backward.sign_transaction(:tx)
        end
      end

      context 'use wallet-level sign_transaction' do
        it 'returns wallet-level sign_transaction' do
          allow(rest_client_mock).to receive(:[]).and_return(true, '01000000000000000000')

          expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332/wallet/wallet.dat", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"signrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
          provider_wallet_level.sign_transaction(:tx)
    
          expect(provider_wallet_level).to receive(:post).with("https://user:password@localhost:8332/wallet/wallet.dat", 60, 60, "{\"method\":\"signrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", {:content_type=>:json}).and_return(rest_client_mock)
          provider_wallet_level.sign_transaction(:tx)
    
          expect(provider_wallet_level).to receive(:request).with(:signrawtransaction, :tx).and_return(rest_client_mock)
          provider_wallet_level.sign_transaction(:tx)
        end
      end
    end

    context '#send_transaction' do
      context 'use node-level send_transaction' do
        it 'returns node-level send_transaction' do
          expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"sendrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
          provider_node_level.send_transaction(:tx)
    
          expect(provider_node_level).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"sendrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", {:content_type=>:json})
          provider_node_level.send_transaction(:tx)
    
          expect(provider_node_level).to receive(:request).with(:sendrawtransaction, :tx)
          provider_node_level.send_transaction(:tx)
        end
      end

      context 'use node-level send_transaction with backward compatibility' do
        it 'returns node-level send_transaction' do
          expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"sendrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
          provider_node_level_backward.send_transaction(:tx)
    
          expect(provider_node_level_backward).to receive(:post).with("https://user:password@localhost:8332", 60, 60, "{\"method\":\"sendrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", {:content_type=>:json})
          provider_node_level_backward.send_transaction(:tx)
    
          expect(provider_node_level_backward).to receive(:request).with(:sendrawtransaction, :tx)
          provider_node_level_backward.send_transaction(:tx)
        end
      end

      context 'use wallet-level send_transaction' do
        it 'returns wallet-level send_transaction' do
          expect(RestClient::Request).to receive(:execute).with(:method => :post, :url => "https://user:password@localhost:8332/wallet/wallet.dat", :timeout => 60, :open_timeout => 60, :payload => "{\"method\":\"sendrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", :headers => {:content_type=>:json})
          provider_wallet_level.send_transaction(:tx)
    
          expect(provider_wallet_level).to receive(:post).with("https://user:password@localhost:8332/wallet/wallet.dat", 60, 60, "{\"method\":\"sendrawtransaction\",\"params\":[\"tx\"],\"id\":\"jsonrpc\"}", {:content_type=>:json})
          provider_wallet_level.send_transaction(:tx)
    
          expect(provider_wallet_level).to receive(:request).with(:sendrawtransaction, :tx)
          provider_wallet_level.send_transaction(:tx)
        end
      end
    end

  end

end