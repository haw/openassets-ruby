# encoding: ascii-8bit

module OpenAssets

  class Api

    include OpenAssets::Util

    attr_reader :config
    attr_reader :provider
    attr_reader :cache

    def initialize(config = nil)
      @cache = {}
      @config = {:network => 'mainnet',
                 :provider => 'bitcoind',
                 :dust_limit => 600,
                 :rpc => { :host => 'localhost', :port => 8332 , :user => '', :password => '', :schema => 'https'}}
      if config
        @config.update(config)
      end
      if @config[:provider] == 'bitcoind'
        @provider = Provider::BitcoinCoreProvider.new(@config[:rpc])
      else
        raise StandardError, 'specified unsupported provider.'
      end
    end

    def provider
      @provider
    end

    def is_testnet?
      @config[:network] == 'testnet'
    end

    # get UTXO for colored coins.
    # @param [Array] address Obtain the balance of this address only, or all addresses if unspecified.
    # @return [Array] Return array of the unspent information Hash.
    def list_unspent(address = [])
      outputs = get_unspent_outputs(address)
      outputs.map {|out|
        script = out.output.script.get_pubkey_address
        {
          'txid' => out.out_point.hash,
          'vout' =>  out.out_point.index,
          'address' =>  script,
          'oa_address' => address_to_oa_address(script),
          'script' => out.output.script,
          'amount' => out.output.value,
          'confirmations' => "",
          'asset_id' => out.output.asset_id,
          'asset_quantity' => out.output.asset_quantity.to_s
        }
      }
    end

    # Returns the balance in both bitcoin and colored coin assets for all of the addresses available in your Bitcoin Core wallet.
    # @param [String] address The open assets address. if unspecified nil.
    def get_balance(address = nil)
      outputs = get_unspent_outputs(address.nil? ? [] : [address])

    end

    # Creates a transaction for issuing an asset.
    # @param[String] from The open asset address to issue the asset from.
    # @param[Integer] amount The amount of asset units to issue.
    # @param[String] to The open asset address to send the asset to; if unspecified, the assets are sent back to the issuing address.
    # @param[String] metadata The metadata to embed in the transaction. The asset definition pointer defined by this metadata.
    # @param[Integer] fees The fess in satoshis for the transaction.
    def issue_asset(from, amount, to = nil, metadata = nil, fees = nil)
      to = from if to.ni?
      builder = OpenAssets::Transaction::TransactionBuilder.new(@config[:dust_limit])
      result = get_unspent_outputs(from)
      # issue_param = OpenAssets::Transaction::TransferParameters.new(result, )
    end

    private
    # Get unspent outputs.
    # @param [Array] addresses The array of address.
    # @return [Array[OpenAssets::Transaction::SpendableOutput]] The array of unspent outputs.
    def get_unspent_outputs(addresses)
      unspent = provider.list_unspent(addresses)
      result = unspent.map{|item|
        OpenAssets::Transaction::SpendableOutput.new(
          OpenAssets::Transaction::OutPoint.new(item['txid'], item['vout']),
          get_output(item['txid'], item['vout'])
        )
      }
      result
    end

    def get_output(txid, output_index)
      cached_output = @cache[txid + output_index.to_s]
      return cached_output if cached_output
      decode_tx = provider.get_transaction(txid, 0)
      raise OpenAssets::Transaction::TransactionBuildError, "txid #{txid} could not be retrieved." if decode_tx.nil?
      tx = Bitcoin::Protocol::Tx.new([decode_tx].pack("H*"))
      colored_outputs = get_color_transaction(tx)
      colored_outputs.each_with_index { |o, index | @cache[txid + index.to_s] = o}
      colored_outputs[output_index]
    end

    def get_color_transaction(tx)
      unless tx.is_coinbase?
        tx.outputs.each_with_index { |out, i|
          marker_output_payload = OpenAssets::Protocol::MarkerOutput.parse_script(out.pk_script)
          unless marker_output_payload.nil?
            marker_output = OpenAssets::Protocol::MarkerOutput.deserialize_payload(marker_output_payload)
            inputs = tx.inputs.map {|input|
              get_output(input.previous_output, input.prev_out_index)
            }
            asset_ids = compute_asset_ids(inputs, i, tx.outputs, marker_output.asset_quantities)
            return asset_ids unless asset_ids.nil?
          end
        }
      end
      tx.outputs.map{|out| OpenAssets::Protocol::TransactionOutput.new(out.value, out.parsed_script, nil, 0, OpenAssets::Protocol::OutputType::UNCOLORED)}
    end

    # @param [Array[OpenAssets::Protocol::TransactionOutput] inputs The outputs referenced by the inputs of the transaction.
    # @param [Integer] marker_output_index The position of the marker output in the transaction.
    # @param [Array[Bitcoin::Protocol::TxOUt]] outputs The outputs of the transaction.
    # @param [Array[Integer]] asset_quantities The list of asset quantities of the outputs.
    def compute_asset_ids(inputs, marker_output_index, outputs, asset_quantities)
      return nil if asset_quantities.length > outputs.length || inputs.length == 0
      result = []

      # Add the issuance outputs
      issuance_asset_id = generate_asset_id(inputs[0].script.to_string)

      for i in 0..marker_output_index
        value = outputs[i].value
        script = outputs[i].parsed_script
        if i < asset_quantities.length && asset_quantities[i] > 0
          output = OpenAssets::Protocol::TransactionOutput.new(value, script, issuance_asset_id, asset_quantities[i], OpenAssets::Protocol::OutputType::ISSUANCE)
        else
          output = OpenAssets::Protocol::TransactionOutput.new(value, script, nil, 0, OpenAssets::Protocol::OutputType::ISSUANCE)
        end
        result << output
      end

      # Add the marker output
      marker_output = outputs[marker_output_index]
      result << OpenAssets::Protocol::TransactionOutput.new(marker_output.value, marker_output.parsed_script, nil, 0, OpenAssets::Protocol::OutputType::MARKER_OUTPUT)

      # Add the transfer outputs
      input_enum = inputs.each
      input_units_left = 0
      for i in marker_output_index + 1 .. outputs.length
        output_asset_quantity = (i <= asset_quantities.length) ? asset_quantities[i-1] : 0
        output_units_left = output_asset_quantity
        asset_id = nil
        while output_units_left > 0
          if input_units_left == 0
            begin
            current_input = input_enum.next
            input_units_left = current_input.asset_quantity
            rescue StopIteration => e
              return nil
            end
          end
          unless current_input.asset_id.nil?
            progress = [input_units_left, output_units_left].min
            output_units_left -= progress
            input_units_left -= progress
            if asset_id.nil?
              # This is the first input to map to this output
              asset_id = current_input.asset_id
            elsif asset_id != current_input.asset_id
              return nil
            end
          end
        end
        result << OpenAssets::Protocol::TransactionOutput.new(outputs[i-1].value, outputs[i-1].parsed_script, asset_id, output_asset_quantity, OpenAssets::Protocol::OutputType::TRANSFER)
      end
      result
    end


  end

end