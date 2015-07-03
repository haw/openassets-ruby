module OpenAssets
  module Protocol

    # Represents a transaction output and its asset ID and asset quantity.
    class TransactionOutput
      attr_accessor :value
      attr_accessor :script
      attr_accessor :asset_id
      attr_accessor :asset_quantity
      attr_accessor :output_type

      def initialize(value, script, asset_id, asset_quantity = 0, output_type = OutputType::UNCOLORED)
        raise ArgumentError, "invalid output_type : #{output_type}" unless OutputType.all.include?(output_type)
        raise ArgumentError, "invalid asset_quantity asset_quantity should be unsignd integer. " unless asset_quantity.between?(0, MarkerOutput::MAX_ASSET_QUANTITY)
        @value = value
        @script = script
        @asset_id = asset_id
        @asset_quantity = asset_quantity
        @output_type = output_type
      end
    end

  end
end