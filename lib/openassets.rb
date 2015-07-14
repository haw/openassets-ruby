require 'bitcoin'
module OpenAssets

  autoload :Protocol, 'openassets/protocol'
  autoload :Transaction, 'openassets/transaction'
  autoload :VERSION, 'openassets/version'
  autoload :Util, 'openassets/util'

  @config = {}

  class << self

    attr_reader :config

    def config=(config)
      if Hash === config
        @config = config
      else
        raise ArgumentError, 'configuration object must be a hash.'
      end
    end

    def is_testnet?
      @config[:network] == 'testnet'
    end

  end

end