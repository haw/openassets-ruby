module OpenAssets
  module Provider
    autoload :BlockChainProviderBase, 'openassets/provider/block_chain_provider_base'
    autoload :BitcoinCoreProvider, 'openassets/provider/bitcoin_core_provider'
    autoload :ApiError, 'openassets/provider/api_error'
  end
end