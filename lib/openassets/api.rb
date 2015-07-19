module OpenAssets

  class Api

    include OpenAssets::Util

    attr_reader :config
    attr_reader :provider

    def initialize(config = nil)
      @config = {:network => 'mainnet',
                 :provider => 'bitcoind',
                 :rpc => { :host => 'localhost', :port => 8332 , :user => '', :password => '', :schema => 'https'}}
      if config
        @config.update(config)
      end
      if @config[:provider] == 'bitcoind'
        @provider = Provider::BitcoinCoreProvider.new(@config[:rpc])
      else
        raise StandardError, 'specified unsupported provider.'
      end
    end

    def provider
      @provider
    end

    def is_testnet?
      @config[:network] == 'testnet'
    end

    # get UTXO for colored coins.
    # @param [Array] address Obtain the balance of this address only, or all addresses if unspecified.
    def list_unspent(address = [])
      result = []
      unspents = provider.list_unspent(address)
      unspents.each do |unspent|
        result << {
          'txid' => unspent['txid'],
          'vout' =>  unspent['vout'],
          'address' =>  unspent['address'],
          'oa_address' => address_to_oa_address(unspent['address']),
          'script' => unspent['scriptPubKey'],
          'amount' => unspent['amount'],
          'confirmations' => unspent['confirmations'],
          'asset_id' => nil, #TODO
          'asset_quantity' => '0'} #TODO
      end
      result
    end

  end

end