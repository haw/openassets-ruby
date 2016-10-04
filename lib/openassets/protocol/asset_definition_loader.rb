module OpenAssets
  module Protocol

    class AssetDefinitionLoader
      extend Bitcoin::Util

      attr_reader :loader

      def initialize(url)
        if url.start_with?('http://') || url.start_with?('https://')
          @loader = HttpAssetDefinitionLoader.new(url)
        end
      end

      # load Asset Definition File
      # @return[OpenAssets::Protocol::AssetDefinition] loaded asset definition object
      def load_definition
        @loader.load if @loader
      end

      # create redeem script of asset definition file using p2sh
      # @param[String] url The asset definition url.
      # @return[Bitcoin::Script] redeem script.
      def self.create_pointer_redeem_script(url)
        asset_def = "u=#{url}".bytes.map{|b|b.to_s(16)}.join
        Bitcoin::Script.from_string("#{asset_def} OP_DROP")
      end

      # create ps2s script which specify asset definition pointer
      # @param[String] url The asset definition url.
      # @return[Bitcoin::Script] p2sh script.
      def self.create_pointer_p2sh(url)
        redeem_script = create_pointer_redeem_script(url)
        Bitcoin::Script.new(Bitcoin::Script.to_p2sh_script(hash160(redeem_script.to_payload.bth)))
      end
    end
  end
end