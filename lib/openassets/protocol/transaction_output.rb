require 'rest-client'

module OpenAssets
  module Protocol

    # Represents a transaction output and its asset ID and asset quantity.
    class TransactionOutput
      attr_accessor :value
      attr_accessor :script
      attr_accessor :asset_id
      attr_accessor :asset_quantity
      attr_accessor :output_type

      attr_accessor :account
      attr_accessor :metadata
      attr_accessor :asset_definition_url
      attr_accessor :asset_definition


      # @param [Integer] value The satoshi value of the output.
      # @param [Bitcoin::Script] script The script controlling redemption of the output.
      # @param [String] asset_id The asset ID of the output.
      # @param [Integer] asset_quantity The asset quantity of the output.
      # @param [OpenAssets::Transaction::OutPutType] output_type The type of the output.
      def initialize(value, script, asset_id = nil, asset_quantity = 0, output_type = OutputType::UNCOLORED, metadata = '')
        raise ArgumentError, "invalid output_type : #{output_type}" unless OutputType.all.include?(output_type)
        raise ArgumentError, "invalid asset_quantity. asset_quantity should be unsignd integer. " unless asset_quantity.between?(0, MarkerOutput::MAX_ASSET_QUANTITY)
        @value = value
        @script = script
        @asset_id = asset_id
        @asset_quantity = asset_quantity
        @output_type = output_type
        @metadata = metadata
        load_asset_definition_url
      end

      # calculate asset amount.
      # asset amount is the value obtained by converting the asset quantity to the unit of divisibility that are defined in the Asset definition file.
      def asset_amount
        d = divisibility
        d > 0 ? (@asset_quantity.to_f / (10 ** d)).to_f : @asset_quantity
      end

      # get divisibility defined by asset definition file.
      def divisibility
        return 0 unless valid_asset_definition?
        @asset_definition.divisibility
      end

      # get Asset definition url that is included metadata.
      private
      def load_asset_definition_url
        @asset_definition_url = ''
        return if @metadata.nil? || @metadata.length == 0
        if @metadata.start_with?('u=')
          @asset_definition = AssetDefinition.parse_url(metadata_url)
          if @asset_definition.include_asset_id?(@asset_id)
            @asset_definition_url = metadata_url
          else
            @asset_definition_url = "The asset definition is invalid. #{metadata_url}"
          end
        else
          @asset_definition_url = 'Invalid metadata format.'
        end
      end

      private

      def metadata_url
        unless @metadata.nil?
           @metadata.slice(2..-1)
        end
      end

      def valid_asset_definition?
        !@asset_definition.nil? && @asset_definition.include_asset_id?(@asset_id)
      end
    end

  end
end