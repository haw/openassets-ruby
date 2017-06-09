require 'rest-client'

module OpenAssets
  module Provider

    # The implementation of BlockChain provider using Bitcoin Core.
    class BitcoinCoreProvider < BlockChainProviderBase

      RPC_API = [
          :addmultisigaddress, :addnode, :backupwallet, :bumpfee, :createmultisig, :createrawtransaction, :decoderawtransaction,
          :decodescript, :dumpprivkey, :dumpwallet, :encryptwallet, :estimatefee, :estimatepriority, :generate, :generatetoaddress,
          :getaccountaddress, :getaccount, :getaddednodeinfo, :getaddressesbyaccount, :getbalance, :getbestblockhash,
          :getblock, :getblockchaininfo, :getblockcount, :getblockhash, :getblockheader, :getchaintips, :getconnectioncount, :getdifficulty,
          :getmempoolancestors, :getmempooldescendants, :getmempoolentry, :clearbanned, :disconnectnode,
          :getgenerate, :gethashespersec, :getinfo, :getmempoolinfo, :getmininginfo, :getnettotals, :getnetworkhashps,
          :getnetworkinfo, :getnewaddress, :getpeerinfo, :getrawchangeaddress, :getrawmempool, :getrawtransaction,
          :getreceivedbyaccount, :getreceivedbyaddress, :gettransaction, :gettxout, :gettxoutproof, :gettxoutsetinfo, :preciousblock, :pruneblockchain,
          :getunconfirmedbalance, :getwalletinfo, :importmulti, :getwork, :help, :importaddress, :importprivkey, :importwallet, :importpubkey,
          :keypoolrefill, :listaccounts, :listaddressgroupings, :listlockunspent, :listreceivedbyaccount, :listreceivedbyaddress,
          :listsinceblock, :listtransactions, :listunspent, :lockunspent, :move, :ping, :prioritisetransaction, :sendfrom,
          :sendmany, :sendrawtransaction, :sendtoaddress, :setaccount, :setgenerate, :settxfee, :signmessage, :signrawtransaction,
          :stop, :submitblock, :validateaddress, :verifychain, :verifymessage, :verifytxoutproof, :walletlock, :walletpassphrase,
          :walletpassphrasechange, :listbanned, :setban, :setnetworkactive, :fundrawtransaction, :estimatesmartfee, :estimatesmartpriority,
          :signmessagewithprivkey, :abandontransaction, :addwitnessaddress, :importprunedfunds, :importpubkey, :removeprunedfunds
      ]

      attr_reader :config

      def initialize(config)
        @config = config
      end

      # Get an array of unspent transaction outputs belonging to this wallet.
      # @param [Array] addresses If present, only outputs which pay an address in this array will be returned.
      # @param [Integer] min The minimum number of confirmations the transaction containing an output must have in order to be returned. Default is 1.
      # @param [Integer] max The maximum number of confirmations the transaction containing an output may have in order to be returned. Default is 9999999.
      def list_unspent(addresses = [], min = 1 , max = 9999999)
        request('listunspent', min, max, addresses)
      end

      # Get raw transaction.
      # @param [String] transaction_hash The transaction hash.
      # @param [String] verbose Whether to get the serialized or decoded transaction. 0: serialized transaction (Default). 1: decode transaction.
      # @return [String] (if verbose=0)—the serialized transaction. (if verbose=1)—the decoded transaction. (if transaction not found)—nil.
      def get_transaction(transaction_hash, verbose = 0)
        begin
          request('getrawtransaction', transaction_hash, verbose)
        rescue OpenAssets::Provider::ApiError => e
          nil
        end
      end

      # Signs a transaction in the serialized transaction format using private keys.
      # @param [String] tx The serialized format transaction.
      # @return [Bitcoin::Protocol::Tx] The signed transaction.
      def sign_transaction(tx)
        signed_tx = request('signrawtransaction', tx)
        raise OpenAssets::Error, 'Could not sign the transaction.' unless signed_tx['complete']
        Bitcoin::Protocol::Tx.new(signed_tx['hex'].htb)
      end

      # Validates a transaction and broadcasts it to the peer-to-peer network.
      # @param [String] tx The serialized format transaction.
      # @return [String] The TXID or error message.
      def send_transaction(tx)
        request('sendrawtransaction', tx)
      end

      # Adds an address or pubkey script to the wallet without the associated private key, allowing you to watch for transactions affecting that address or pubkey script without being able to spend any of its outputs.
      # @param [String] address Either a P2PKH or P2SH address encoded in base58check, or a pubkey script encoded as hex.
      def import_address(address)
        request('importaddress', address)
      end

      def method_missing(method, *params)
        super unless RPC_API.include?(method)
        request(method, *params)
      end

      private
      # Convert decode tx string to Bitcion::Protocol::Tx
      def decode_tx_to_btc_tx(tx)
        hash = {
          'version' => tx['version'],
          'lock_time' => tx['locktime'],
          'hex' => tx['hex'],
          'txid' => tx['txid'],
          'blockhash' => tx['blockhash'],
          'confirmations' => tx['confirmations'],
          'time' => tx['time'],
          'blocktime' => tx['blocktime'],
          'in' => tx['vin'].map{|input|
            {'output_index' => input['vout'], 'previous_transaction_hash' => input['txid'], 'coinbase' => input['coinbase'],
             'scriptSig' => input['scriptSig']['asm'], 'sequence' => input['sequence']}},
          'out' => tx['vout'].map{|out|
            {'amount' => out['value'], 'scriptPubKey' => out['scriptPubKey']['asm']}
          }
        }
        Bitcoin::Protocol::Tx.from_hash(hash)
      end

      private
      def server_url
        url = "#{@config[:schema]}://"
        url.concat "#{@config[:user]}:#{@config[:password]}@"
        url.concat "#{@config[:host]}:#{@config[:port]}"
        url
      end

      def request(command, *params)
        data = {
          :method => command,
          :params => params,
          :id => 'jsonrpc'
        }
        post(server_url, @config[:timeout], @config[:open_timeout], data.to_json, content_type: :json) do |respdata, request, result|
          raise ApiError, result.message if !result.kind_of?(Net::HTTPSuccess) && respdata.empty?
          response = JSON.parse(respdata.gsub(/\\u([\da-fA-F]{4})/) { [$1].pack('H*').unpack('n*').pack('U*').encode('ISO-8859-1').force_encoding('UTF-8') })
          raise ApiError, response['error'] if response['error']
          response['result']
        end
      end

      def post(url, timeout, open_timeout, payload, headers={}, &block)
        RestClient::Request.execute(:method => :post, :url => url, :timeout => timeout, :open_timeout => open_timeout, :payload => payload, :headers => headers, &block)
      end
    end
  end
end