module OpenAssets
  module Transaction

    class TransactionBuilder

      # The minimum allowed output value.
      attr_accessor :amount

      def initialize(amount = 600)
        @amount = amount
      end

      # issue asset.
      # @param [TransferParameters] issue_spec The parameters of the issuance.
      # @param [bytes] metadata The metadata to be embedded in the transaction.
      # @param [Integer] fees The fees to include in the transaction.
      # @return An unsigned transaction for issuing asset.
      def issue_asset(issue_spec, metadata, fees)
        inputs, total_amount = collect_uncolored_outputs(issue_spec.unspent_outputs, 2 * @amount + fees)
      end

      def transfer_assets

      end

      def transfer_btc

      end

      # collect uncolored outputs in unspent outputs(contains colored output).
      # @param [Array[OpenAssets::Transaction::SpendableOutput]] unspent_outputs The Array of available outputs.
      # @param [Integer] amount The amount to collect.
      # @return [Array] inputs, total_amount
      def self.collect_uncolored_outputs(unspent_outputs, amount)
        total_amount = 0
        results = []
        unspent_outputs.each do |output|
          if output.output.asset_id.nil?
            results << output
            total_amount += output.output.value
          end
          return results, total_amount if total_amount >= amount
        end
        raise InsufficientFundsError
      end

    end

  end
end