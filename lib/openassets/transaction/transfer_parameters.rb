module OpenAssets
  module Transaction

    # The value object of a bitcoin or asset transfer.
    class TransferParameters

      attr_accessor :unspent_outputs
      attr_accessor :amount
      attr_accessor :change_script
      attr_accessor :to_script

      # initialize
      # @param [Array[OpenAssets::Transaction::SpendableOutput]] unspent_outputs Array of the unspent outputs available for the transaction.
      # @param [String] to_script the output script to which to send the assets or bitcoins.
      # @param [String] change_script the output script to which to send any remaining change.
      # @param [Integer] amount The asset quantity or amount of the satoshi sent in the transaction.
      def initialize(unspent_outputs, to_script, change_script, amount)
        @unspent_outputs = unspent_outputs
        @to_script = to_script
        @change_script = change_script
        @amount = amount
      end

    end

  end
end