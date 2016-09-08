module OpenAssets
  module Protocol

    # Asset Definition loader for http or https uri scheme
    class HttpAssetDefinitionLoader

      attr_reader :url

      def initialize(url)
        @url = url
      end

      # load asset definition
      def load
        begin
          definition = AssetDefinition.parse_json(RestClient::Request.execute(:method => :get, :url => url, :timeout => 10, :open_timeout => 10))
          definition.asset_definition_url = url
          definition
        rescue => e
          puts e
          nil
        end
      end

    end
  end
end