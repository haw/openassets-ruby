module OpenAssets
  module Protocol

    class AssetDefinitionLoader
      extend Bitcoin::Util
      extend OpenAssets::Util

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
      # @param[String] to The open asset address to send the asset to.
      # @return[Bitcoin::Script] redeem script.
      def self.create_pointer_redeem_script(url, to)
        asset_def = "u=#{url}".bytes.map{|b|b.to_s(16)}.join
        btc_addr = oa_address_to_address(to)
        script = Bitcoin::Script.from_string("#{asset_def}")
        puts Bitcoin::Script.to_address_script(btc_addr).bth
        Bitcoin::Script.new(script.append_opcode(Bitcoin::Script::OP_DROP).to_payload + Bitcoin::Script.to_address_script(btc_addr))
      end

      # create ps2s script which specify asset definition pointer
      # @param[String] url The asset definition url.
      # @param[String] to The open asset address to send the asset to.
      # @return[Bitcoin::Script] p2sh script.
      def self.create_pointer_p2sh(url, to)
        redeem_script = create_pointer_redeem_script(url, to)
        Bitcoin::Script.new(Bitcoin::Script.to_p2sh_script(hash160(redeem_script.to_payload.bth)))
      end
    end
  end
end