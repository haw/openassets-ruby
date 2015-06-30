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
      # @return [String] The serialized payload.
      def to_payload
        payload = [OAP_MARKER, VERSION]
        payload << Bitcoin::Protocol.pack_var_int(@asset_quantities.length).unpack("H*")
        @asset_quantities.map{|q|payload << encode_leb128(q)}
        payload << Bitcoin::Protocol.pack_var_int(@metadata.length).unpack("H*")
        tmp = []
        @metadata.bytes{|b| tmp << b.to_s(16)}
        payload << tmp.join
        payload.join
      end

      # Deserialize the marker output payload.
      # @param [bytes] payload The Open Assets Payload.
      # @return [OpenAssets::Protocol::MarkerOutput] The marker output object.
      def self.deserialize_payload(paylaod)

      end

    end

  end
end