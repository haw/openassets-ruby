module OpenAssets
  module Protocol

    class MarkerOutput
      include OpenAssets::Util

      # A tag indicating thath this transaction is an Open Assets transaction.
      OAP_MARKER = "4f41"
      # The major revision number of the Open Assets Protocol.(1=0x0100)
      VERSION = "0100"

      attr_accessor :asset_quantities
      attr_accessor :metadata

      # @param [Array] asset_quantities The asset quantity array
      # @param [bytes] metadata The metadata in the marker output.
      def initialize(asset_quantities, metadata)
        @asset_quantities = asset_quantities
        @metadata = metadata
      end

      # Serialize the marker output into a Open Assets Payload buffer.
      # @return [bytes] The serialized payload.
      def to_payload
        payload = [OAP_MARKER, VERSION]
        require 'pp'
        payload << Bitcoin::Protocol.pack_var_int(@asset_quantities.length)
        @asset_quantities.map{|q|
          payload << encode_leb128(q)
        }
        payload << Bitcoin::Protocol.pack_var_int(@metadata.length).to_s
        payload << @metadata
        payload
      end

      # Deserialize the marker output payload.
      # @param [bytes] payload The Open Assets Payload.
      # @return [OpenAssets::Protocol::MarkerOutput] The marker output object.
      def self.deserialize_payload(paylaod)

      end

    end

  end
end