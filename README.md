# openassets-ruby
The implementation of the Open Assets Protocol for Ruby.

# Usage

Initialize the connection information to the bitcoind.

    require 'openassets'
    
    api = OpenAssets::Api.new({:network => 'mainnet',
                         :provider => 'bitcoind',
                         :dust_limit => 600,
                         :rpc => {:user => 'xxx', :password => 'xxx', :schema => 'http', :port => 8332, :host => 'localhost'}})
                         

* listunspent: Returns an array of unspent transaction outputs, augmented with the asset ID and quantity of each output.
  
  
    api.list_unspent
    
    
Other api now development.