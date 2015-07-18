module OpenAssets

  class Api

    attr_accessor :config

    def initialize(config = nil)
      if config
        @config = config
      else
        @config = {:network => 'mainnet'}
      end
    end


    def is_testnet?
      @config[:network] == 'testnet'
    end

    private
    def config=(config)
      if Hash === config
        @config = config
      else
        raise ArgumentError, 'configuration object must be a hash.'
      end
    end
  end

end