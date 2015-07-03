module OpenAssets
  module Transaction

    # The value object of a bitcoin or asset transfer.
    class TransferParameters

      # Array of the unspent outputs available for the transaction.
      attr_accessor :unspent_outputs
      # The asset quantity or amount of the satoshi sent in the transaction.
      attr_accessor :amount
      # byte array of the output script to which to send any remaining change.
      attr_accessor :change_script
      # byte array of the output script to which to send the assets or bitcoins.
      attr_accessor :to_script

      def initialize(unspent_outputs, to_script, change_script, amount)
        @unspent_outputs = unspent_outputs
        @to_script = to_script
        @change_script = change_script
        @amount = amount
      end

    end

  end
end