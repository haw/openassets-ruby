# encoding: ascii-8bit

module OpenAssets

  class Api

    include Util
    include MethodFilter

    before_filter :change_network, {:include => [:list_unspent, :get_balance, :issue_asset, :send_asset, :send_assets, :send_bitcoin]}

    attr_reader :config
    attr_reader :provider
    attr_reader :tx_cache

    def initialize(config = nil)
      @config = {:network => 'mainnet',
                 :provider => 'bitcoind', :cache => 'cache.db',
                 :dust_limit => 600, :default_fees => 10000, :min_confirmation => 1, :max_confirmation => 9999999,
                 :rpc => { :host => 'localhost', :port => 8332 , :user => '', :password => '', :schema => 'https'}}
      if config
        @config.update(config)
      end
      OpenAssets.configuration = @config
      if @config[:provider] == 'bitcoind'
        @provider = Provider::BitcoinCoreProvider.new(@config[:rpc])
      else
        raise OpenAssets::Error, 'specified unsupported provider.'
      end
      @tx_cache = Cache::TransactionCache.new(@config[:cache])
    end

    def provider
      @provider
    end

    def is_testnet?
      @config[:network] == 'testnet'
    end

    # get UTXO for colored coins.
    # @param [Array] oa_address_list Obtain the balance of this open assets address only, or all addresses if unspecified.
    # @return [Array] Return array of the unspent information Hash.
    def list_unspent(oa_address_list = [])
      btc_address_list = oa_address_list.map { |oa_address| oa_address_to_address(oa_address)}
      outputs = get_unspent_outputs(btc_address_list)
      result = outputs.map{|out| out.to_hash}
      result
    end

    # Returns the balance in both bitcoin and colored coin assets for all of the addresses available in your Bitcoin Core wallet.
    # @param [String] address The open assets address. if unspecified nil.
    def get_balance(address = nil)
      outputs = get_unspent_outputs(address.nil? ? [] : [oa_address_to_address(address)])
      colored_outputs = outputs.map{|o|o.output}
      sorted_outputs = colored_outputs.sort_by { |o|o.script.to_string}
      groups = sorted_outputs.group_by{|o| o.script.to_string}
      result = groups.map{|k, v|
        btc_address = script_to_address(v[0].script)
        sorted_script_outputs = v.sort_by{|o|o.asset_id unless o.asset_id}
        group_assets = sorted_script_outputs.group_by{|o|o.asset_id}.select{|k,v| !k.nil?}
        assets = group_assets.map{|asset_id, outputs|
          {
              'asset_id' => asset_id,
              'quantity' => outputs.inject(0) { |sum, o| sum + o.asset_quantity }.to_s,
              'amount' => outputs.inject(0) { |sum, o| sum + o.asset_amount }.to_s,
              'asset_definition_url' => outputs[0].asset_definition_url,
              'proof_of_authenticity' => outputs[0].proof_of_authenticity
          }
        }
        {
            'address' => btc_address,
            'oa_address' => btc_address.nil? ? nil : address_to_oa_address(btc_address),
            'value' => satoshi_to_coin(v.inject(0) { |sum, o|sum +  o.value}),
            'assets' => assets,
            'account' => v[0].account
        }
      }
      address.nil? ? result : result.select{|r|r['oa_address'] == address}
    end

    # Creates a transaction for issuing an asset.
    # @param[String] from The open asset address to issue the asset from.
    # @param[Integer] amount The amount of asset units to issue.
    # @param[String] to The open asset address to send the asset to; if unspecified, the assets are sent back to the issuing address.
    # @param[String] metadata The metadata to embed in the transaction. The asset definition pointer defined by this metadata.
    # @param[Integer] fees The fess in satoshis for the transaction.
    # @param[String] mode Specify the following mode.
    # 'broadcast' (default) for signing and broadcasting the transaction,
    # 'signed' for signing the transaction without broadcasting,
    # 'unsigned' for getting the raw unsigned transaction without broadcasting"""='broadcast'
    # @param[Integer] output_qty The number of divides the issue output. Default value is 1.
    # Ex. amount = 125 and output_qty = 2, asset quantity = [62, 63] and issue TxOut is two.
    # @return[Bitcoin::Protocol::Tx] The Bitcoin::Protocol::Tx object.
    def issue_asset(from, amount, metadata = nil, to = nil, fees = nil, mode = 'broadcast', output_qty = 1)
      to = from if to.nil?
      colored_outputs = get_unspent_outputs([oa_address_to_address(from)])
      issue_param = OpenAssets::Transaction::TransferParameters.new(colored_outputs, to, from, amount, output_qty)
      tx = create_tx_builder.issue_asset(issue_param, metadata, fees.nil? ? @config[:default_fees]: fees)
      tx = process_transaction(tx, mode)
      tx
    end

    # Creates a transaction for sending an asset from an address to another.
    # @param[String] from The open asset address to send the asset from.
    # @param[String] asset_id The asset ID identifying the asset to send.
    # @param[Integer] amount The amount of asset units to send.
    # @param[String] to The open asset address to send the asset to.
    # @param[Integer] fees The fess in satoshis for the transaction.
    # @param[String] mode 'broadcast' (default) for signing and broadcasting the transaction,
    # 'signed' for signing the transaction without broadcasting,
    # 'unsigned' for getting the raw unsigned transaction without broadcasting"""='broadcast'
    # @return[Bitcoin::Protocol:Tx] The resulting transaction.
    def send_asset(from, asset_id, amount, to, fees = nil, mode = 'broadcast', output_qty = 1)
      colored_outputs = get_unspent_outputs([oa_address_to_address(from)])
      asset_transfer_spec = OpenAssets::Transaction::TransferParameters.new(colored_outputs, to, from, amount, output_qty)
      tx = create_tx_builder.transfer_asset(asset_id, asset_transfer_spec, from, fees.nil? ? @config[:default_fees]: fees)
      tx = process_transaction(tx, mode)
      tx
    end

    # Creates a transaction for sending multiple asset from an address to another.
    # @param[String] from The open asset address to send the asset from.
    # @param[Array[OpenAssets::SendAssetParam]] send_asset_params The send Asset information(asset_id, amount, to).
    # @param[Integer] fees The fess in satoshis for the transaction.
    # @param[String] mode 'broadcast' (default) for signing and broadcasting the transaction,
    # 'signed' for signing the transaction without broadcasting,
    # 'unsigned' for getting the raw unsigned transaction without broadcasting"""='broadcast'
    # @return[Bitcoin::Protocol:Tx] The resulting transaction.
    def send_assets(from, send_asset_params, fees = nil, mode = 'broadcast')
      colored_outputs = get_unspent_outputs([oa_address_to_address(from)])
      transfer_specs = send_asset_params.map{|param|
        [param.asset_id, OpenAssets::Transaction::TransferParameters.new(colored_outputs, param.to, from, param.amount)]
      }
      tx = create_tx_builder.transfer_assets(transfer_specs, from, fees.nil? ? @config[:default_fees]: fees)
      tx = process_transaction(tx, mode)
      tx
    end

    # Creates a transaction for sending bitcoins from an address to another.
    # @param[String] from The address to send the bitcoins from.
    # @param[Integer] amount The amount of satoshis to send.
    # @param[String] to The address to send the bitcoins to.
    # @param[Integer] fees The fess in satoshis for the transaction.
    # @param[String] mode 'broadcast' (default) for signing and broadcasting the transaction,
    # 'signed' for signing the transaction without broadcasting,
    # 'unsigned' for getting the raw unsigned transaction without broadcasting"""='broadcast'
    # @param [Integer] output_qty The number of divides the issue output. Default value is 1.
    # Ex. amount = 125 and output_qty = 2, asset quantity = [62, 63] and issue TxOut is two.
    # @return[Bitcoin::Protocol:Tx] The resulting transaction.
    def send_bitcoin(from, amount, to, fees = nil, mode = 'broadcast', output_qty = 1)
      validate_address([from, to])
      colored_outputs = get_unspent_outputs([from])
      btc_transfer_spec = OpenAssets::Transaction::TransferParameters.new(colored_outputs, to, from, amount, output_qty)
      tx = create_tx_builder.transfer_btc(btc_transfer_spec, fees.nil? ? @config[:default_fees]: fees)
      process_transaction(tx, mode)
    end

    # Creates a transaction for burn asset.
    # @param[String] oa_address The open asset address to burn asset.
    # @param[String] asset_id The asset ID identifying the asset to burn.
    # @param[Integer] fees The fess in satoshis for the transaction.
    # @param[String] mode 'broadcast' (default) for signing and broadcasting the transaction,
    # 'signed' for signing the transaction without broadcasting,
    # 'unsigned' for getting the raw unsigned transaction without broadcasting"""='broadcast'
    def burn_asset(oa_address, asset_id, fees = nil, mode = 'broadcast')
      unspents = get_unspent_outputs([oa_address_to_address(oa_address)])
      tx = create_tx_builder.burn_asset(unspents, asset_id, fees.nil? ? @config[:default_fees]: fees)
      process_transaction(tx, mode)
    end

    # Get unspent outputs.
    # @param [Array] addresses The array of Bitcoin address.
    # @return [Array[OpenAssets::Transaction::SpendableOutput]] The array of unspent outputs.
    def get_unspent_outputs(addresses)
      validate_address(addresses)
      unspent = provider.list_unspent(addresses, @config[:min_confirmation], @config[:max_confirmation])
      result = unspent.map{|item|
        output_result = get_output(item['txid'], item['vout'])
        output_result.account = item['account']
        output = OpenAssets::Transaction::SpendableOutput.new(
          OpenAssets::Transaction::OutPoint.new(item['txid'], item['vout']), output_result)
        output.confirmations = item['confirmations']
        output
      }
      result
    end

    def get_output(txid, output_index)
      decode_tx = load_cached_tx(txid)
      tx = Bitcoin::Protocol::Tx.new(decode_tx.htb)
      colored_outputs = get_color_outputs_from_tx(tx)
      colored_outputs[output_index]
    end

    def get_color_outputs_from_tx(tx)
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

    # Get tx outputs.
    # @param[String] txid Transaction ID.
    # @param[Boolean] use_cache If specified true use cache.(default value is false)
    # @return[Array] Return array of the transaction output Hash with coloring information.
    def get_outputs_from_txid(txid, use_cache = false)
      tx = get_tx(txid, use_cache)
      outputs = get_color_outputs_from_tx(tx)
      outputs.map.with_index{|out, i|out.to_hash.merge({'txid' => tx.hash, 'vout' => i})}
    end

    # Get tx. (This method returns plain Bitcoin::Protocol::Tx object, so it not contains open asset information.)
    # @param[String] txid Transaction ID.
    # @return[Bitcoin::Protocol::Tx] Return the Bitcoin::Protocol::Tx.
    def get_tx(txid, use_cache = true)
      decode_tx = use_cache ? load_cached_tx(txid) : load_tx(txid)
      Bitcoin::Protocol::Tx.new(decode_tx.htb)
    end

    private
    # @param [Array[OpenAssets::Protocol::TransactionOutput] inputs The outputs referenced by the inputs of the transaction.
    # @param [Integer] marker_output_index The position of the marker output in the transaction.
    # @param [Array[Bitcoin::Protocol::TxOut]] outputs The outputs of the transaction.
    # @param [Array[OpenAssets::Protocol::TransactionOutput]] asset_quantities The list of asset quantities of the outputs.
    def compute_asset_ids(inputs, marker_output_index, outputs, asset_quantities)
      return nil if asset_quantities.length > outputs.length - 1 || inputs.length == 0
      result = []

      marker_output = outputs[marker_output_index]

      # Add the issuance outputs
      issuance_asset_id = pubkey_hash_to_asset_id(inputs[0].script.get_hash160)

      for i in (0..marker_output_index-1)
        value = outputs[i].value
        script = outputs[i].parsed_script
        if i < asset_quantities.length && asset_quantities[i] > 0
          payload = OpenAssets::Protocol::MarkerOutput.parse_script(marker_output.parsed_script.to_payload)
          metadata = OpenAssets::Protocol::MarkerOutput.deserialize_payload(payload).metadata
          if metadata.nil?
            output = OpenAssets::Protocol::TransactionOutput.new(value, script, issuance_asset_id, asset_quantities[i], OpenAssets::Protocol::OutputType::ISSUANCE)
          else
            output = OpenAssets::Protocol::TransactionOutput.new(
                value, script, issuance_asset_id, asset_quantities[i], OpenAssets::Protocol::OutputType::ISSUANCE, metadata)
          end
        else
          output = OpenAssets::Protocol::TransactionOutput.new(value, script, nil, 0, OpenAssets::Protocol::OutputType::ISSUANCE)
        end
        result << output
      end

      # Add the marker output
      result << OpenAssets::Protocol::TransactionOutput.new(marker_output.value, marker_output.parsed_script, nil, 0, OpenAssets::Protocol::OutputType::MARKER_OUTPUT)

      # Add the transfer outputs
      input_enum = inputs.each
      input_units_left = 0
      index = 0
      for i in (marker_output_index + 1)..(outputs.length-1)
        output_asset_quantity = (i <= asset_quantities.length) ? asset_quantities[i-1] : 0
        output_units_left = output_asset_quantity
        asset_id = nil
        metadata = nil
        while output_units_left > 0
          index += 1
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
              metadata = current_input.metadata
            elsif asset_id != current_input.asset_id
              return nil
            end
          end
        end
        result << OpenAssets::Protocol::TransactionOutput.new(outputs[i].value, outputs[i].parsed_script,
                                                              asset_id, output_asset_quantity, OpenAssets::Protocol::OutputType::TRANSFER, metadata)
      end
      result
    end

    def process_transaction(tx, mode)
      if mode == 'broadcast' || mode == 'signed'
        # sign the transaction
        signed_tx = provider.sign_transaction(tx.to_payload.bth)
        if mode == 'broadcast'
          puts provider.send_transaction(signed_tx.to_payload.bth)
        end
        signed_tx
      else
        tx
      end
    end

    def change_network
      if is_testnet?
        Bitcoin.network = :testnet3
      else
        Bitcoin.network = :bitcoin
      end
    end

    def create_tx_builder
      OpenAssets::Transaction::TransactionBuilder.new(@config[:dust_limit])
    end

    def load_tx(txid)
      decode_tx = provider.get_transaction(txid, 0)
      raise OpenAssets::Transaction::TransactionBuildError, "txid #{txid} could not be retrieved." if decode_tx.nil?
      decode_tx
    end

    def load_cached_tx(txid)
      decode_tx = tx_cache.get(txid)
      if decode_tx.nil?
        decode_tx = load_tx(txid)
        tx_cache.put(txid, decode_tx)
      end
      decode_tx
    end

  end

end