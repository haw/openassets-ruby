module OpenAssets

  class Api

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

    def is_testnet?
      @config[:network] == 'testnet'
    end

    # get UTXO for colored coins.
    # @param [String] address Obtain the balance of this address only, or all addresses if unspecified.
    def list_unspent(address = nil)
      result = []
      puts "listunpent = #{@provider.list_unspent}"
      result
    end

  end

end