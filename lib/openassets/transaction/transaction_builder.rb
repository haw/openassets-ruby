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

      end

      def transfer_assets

      end

      def transfer_btc

      end

      # collect uncolored outputs.
      # @param [] unspent_outputs The Array of available outputs.
      # @param [Integer] amount The amount to collect.
      def self.collect_uncolored_outputs(unspent_outputs, amount)

      end

    end

  end
end