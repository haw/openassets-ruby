module OpenAssets
  module Protocol

    class MarkerOutput
      include OpenAssets::Util
      extend OpenAssets::Util

      MAX_ASSET_QUANTITY = 2 ** 63 -1

      # A tag indicating thath this transaction is an Open Assets transaction.
      OAP_MARKER = "4f41"
      # The major revision number of the Open Assets Protocol.(1=0x0100)
      VERSION = "0100"

      attr_accessor :asset_quantities
      attr_accessor :metadata

      # @param [Array] asset_quantities The asset quantity array
      # @param [String] metadata The metadata in the marker output.
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
      # @param [String] payload The Open Assets Payload.
      # @return [OpenAssets::Protocol::MarkerOutput] The marker output object.
      def self.deserialize_payload(payload)
        payload = payload[8..-1] # exclude OAP_MARKER,VERSION
        asset_quantity, payload = parse_asset_qty(payload)
        list = to_bytes(payload).map{|x|(x.to_i(16)>=128 ? x : x+"|")}.join.split('|')[0..(asset_quantity - 1)].join
        asset_quantities = decode_leb128(list)
        meta = to_bytes(payload[list.size..-1])
        metadata = meta[1..-1].map{|x|x.to_i(16).chr}.join
        new(asset_quantities, metadata)
      end

      # Parses an output and returns the payload if the output matches the right pattern for a marker output,
      # @param [Bitcoin::Script] output_script: The output script to be parsed.
      # @return [ByteArray] The marker output payload if the output fits the pattern, nil otherwise.
      def self.parse_script(output_script)
        data = output_script.get_op_return_data
        date if data.nil?
        data.start_with?(OAP_MARKER) ? data : nil
      end

      private
      def self.parse_asset_qty(payload)
        bytes = to_bytes(payload)
        case bytes[0]
          when "fd" then
            [(bytes[1]+bytes[2]).to_i(16), payload[6..-1]]
          when "fe" then
            [(bytes[1]+bytes[2]+bytes[3]+bytes[4]).to_i(16),payload[10..-1]]
          else
            [bytes[0].to_i(16),payload[2..-1]]
        end
      end

    end

  end
end