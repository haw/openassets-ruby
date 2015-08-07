module OpenAssets
  module Transaction

    class TransactionBuilder
      include OpenAssets::Util

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
        inputs, total_amount =
            TransactionBuilder.collect_uncolored_outputs(issue_spec.unspent_outputs, 2 * @amount + fees)
        tx = Bitcoin::Protocol::Tx.new
        inputs.each { |spendable|
          script_sig = spendable.output.script.to_binary
          tx_in = Bitcoin::Protocol::TxIn.from_hex_hash(spendable.out_point.hash, spendable.out_point.index)
          tx_in.script_sig = script_sig
          tx.add_in(tx_in)
        }
        issue_address = oa_address_to_address(issue_spec.to_script)
        from_address = oa_address_to_address(issue_spec.change_script)
        validate_address([issue_address, from_address])
        tx.add_out(create_colored_output(issue_address))
        tx.add_out(create_marker_output([issue_spec.amount], metadata))
        tx.add_out(create_uncolored_output(from_address, total_amount - @amount - fees))
        tx
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

      private
      # create colored output.
      # @param [String] address The Bitcoin address.
      # @return [Bitcoin::Protocol::TxOut] colored output
      def create_colored_output(address)
        hash160 = Bitcoin.hash160_from_address(address)
        Bitcoin::Protocol::TxOut.new(@amount,
                                     Bitcoin::Script.new(Bitcoin::Script.to_hash160_script(hash160)).to_payload)
      end

      # create marker output.
      # @param [Array] asset_quantities asset_quantity array.
      # @param [String] metadata
      # @return [Bitcoin::Protocol::TxOut] the marker output.
      def create_marker_output(asset_quantities, metadata)
        script = OpenAssets::Protocol::MarkerOutput.new(asset_quantities, metadata).build_script
        Bitcoin::Protocol::TxOut.new(0, script.to_payload)
      end

      # create an uncolored output.
      # @param [String] address: The Bitcoin address.
      # @param [Integer] value: The satoshi value of the output.
      # @return [Bitcoin::Protocol::TxOut] an uncolored output.
      def create_uncolored_output(address, value)
        raise DustOutputError if value < @amount
        hash160 = Bitcoin.hash160_from_address(address)
        Bitcoin::Protocol::TxOut.new(value, Bitcoin::Script.new(Bitcoin::Script.to_hash160_script(hash160)).to_payload)
      end

    end

  end
end