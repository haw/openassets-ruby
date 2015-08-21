module OpenAssets
  module Transaction

    class TransactionBuilder
      include OpenAssets::Util

      # The minimum allowed output value.
      attr_accessor :amount

      def initialize(amount = 600)
        @amount = amount
      end

      # Creates a transaction for issuing an asset.
      # @param [TransferParameters] issue_spec The parameters of the issuance.
      # @param [bytes] metadata The metadata to be embedded in the transaction.
      # @param [Integer] fees The fees to include in the transaction.
      # @return[Bitcoin:Protocol:Tx] An unsigned transaction for issuing asset.
      def issue_asset(issue_spec, metadata, fees, output_qty = 1)
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
        asset_quantities =[]
        output_qty.times {|index|
          if index == output_qty - 1
            asset_quantities[index] = issue_spec.amount / output_qty + issue_spec.amount % output_qty
          else
            asset_quantities[index] = issue_spec.amount / output_qty
          end
          tx.add_out(create_colored_output(issue_address))
        }
        tx.add_out(create_marker_output(asset_quantities, metadata))
        tx.add_out(create_uncolored_output(from_address, total_amount - @amount - fees))
        tx
      end

      # Creates a transaction for sending an asset.
      # @param[String] asset_id The ID of the asset being sent.
      # @param[OpenAssets::Transaction::TransferParameters] transfer_spec The parameters of the asset being transferred.
      # @param[String] btc_change_script The script where to send bitcoin change, if any.
      # @param[Integer] fees The fees to include in the transaction.
      # @return[Bitcoin::Protocol:Tx] The resulting unsigned transaction.
      def transfer_assets(asset_id, transfer_spec, btc_change_script, fees)
        btc_transfer_spec = OpenAssets::Transaction::TransferParameters.new(transfer_spec.unspent_outputs, nil, btc_change_script, 0)
        outputs = []
        asset_quantities = []
        inputs, total_amount = TransactionBuilder.collect_colored_outputs(transfer_spec.unspent_outputs, asset_id, transfer_spec.amount)

        # add asset transfer outpu
        outputs << create_colored_output(oa_address_to_address(transfer_spec.to_script))
        asset_quantities << transfer_spec.amount

        # add the rest of the asset to the origin address
        if total_amount > transfer_spec.amount
          outputs << create_colored_output(oa_address_to_address(transfer_spec.change_script))
          asset_quantities << (total_amount - transfer_spec.amount)
        end

        btc_excess = inputs.inject(0) { |sum, i| sum + i.output.value } - outputs.inject(0){|sum, o| sum + o.value}
        if btc_excess < btc_transfer_spec.amount + fees
          uncolored_outputs, uncolored_amount =
              TransactionBuilder.collect_uncolored_outputs(btc_transfer_spec.unspent_outputs, btc_transfer_spec.amount + fees - btc_excess)
          inputs << uncolored_outputs
          btc_excess += uncolored_amount
        end

        change = btc_excess - btc_transfer_spec.amount - fees
        if change > 0
          outputs << create_uncolored_output(oa_address_to_address(btc_transfer_spec.change_script), change)
        end

        if btc_transfer_spec.amount > 0
          outputs << create_uncolored_output(oa_address_to_address(btc_transfer_spec.to_script), btc_transfer_spec.amount)
        end

        # add marker output to outputs first.
        unless asset_quantities.empty?
          outputs.unshift(create_marker_output(asset_quantities))
        end

        tx = Bitcoin::Protocol::Tx.new
        inputs.flatten.each{|i|
          script_sig = i.output.script.to_binary
          tx_in = Bitcoin::Protocol::TxIn.from_hex_hash(i.out_point.hash, i.out_point.index)
          tx_in.script_sig = script_sig
          tx.add_in(tx_in)
        }
        outputs.each{|o|tx.add_out(o)}
        tx
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

      # Returns a list of colored outputs for the specified quantity.
      # @param[Array[OpenAssets::Transaction::SpendableOutput]] unspent_outputs
      # @param[String] asset_id The ID of the asset to collect.
      # @param[Integer] asset_quantity The asset quantity to collect.
      # @return[Array[OpenAssets::Transaction::SpendableOutput], int] A list of outputs, and the total asset quantity collected.
      def self.collect_colored_outputs(unspent_outputs, asset_id, asset_quantity)
        total_amount = 0
        result = []
        unspent_outputs.each do |output|
          if output.output.asset_id == asset_id
            result << output
            total_amount += output.output.asset_quantity
          end
          return result, total_amount if total_amount >= asset_quantity
        end
        raise InsufficientAssetQuantityError
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
      def create_marker_output(asset_quantities, metadata = '')
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