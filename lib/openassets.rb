require 'bitcoin'
require 'leb128'

module OpenAssets

  autoload :Protocol, 'openassets/protocol'
  autoload :Transaction, 'openassets/transaction'
  autoload :VERSION, 'openassets/version'
  autoload :Util, 'openassets/util'
  autoload :MethodFilter, 'openassets/medhod_filter'
  autoload :Api, 'openassets/api'
  autoload :Provider, 'openassets/provider'
  autoload :Error, 'openassets/error'
  autoload :SendAssetParam, 'openassets/send_asset_param'
  autoload :SendBitcoinParam, 'openassets/send_bitcoin_param'
  autoload :Cache, 'openassets/cache'

  class << self
    attr_accessor :configuration
  end

  extend Util
end