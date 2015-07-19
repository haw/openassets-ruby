require 'rest-client'

module OpenAssets
  module Provider

    # The implementation of BlockChain provider using Bitcoin Core.
    class BitcoinCoreProvider < BlockChainProviderBase

      attr_reader :config

      def initialize(config)
        @config = config
      end

      def list_unspent
        request('listunspent')
      end

      private
      def server_url
        url = "#{@config[:schema]}://"
        url.concat "#{@config[:user]}:#{@config[:password]}@"
        url.concat "#{@config[:host]}:#{@config[:port]}"
        puts url
        url
      end

      def request(command, *params)
        puts params.nil?
        data = {
          :method => command,
          :params => params,
          :id => 'jsonrpc'
        }
        puts data
        RestClient.post(server_url, data.to_json, content_type: :json) do |respdata, request, result|
          response = JSON.parse(respdata)
          raise ApiError, response['error'] if response['error']
          response['result']
        end
      end

    end
  end
end