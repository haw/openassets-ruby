module OpenAssets
  module Protocol

    class AssetDefinitionLoader

      attr_reader :loader

      def initialize(metadata)
        if metadata.start_with?('http://') || metadata.start_with?('https://')
          @loader = HttpAssetDefinitionLoader.new(metadata)
        end
      end

      # load Asset Definition File
      # @return[OpenAssets::Protocol::AssetDefinition] loaded asset definition object
      def load_definition
        @loader.load
      end

    end
  end
end