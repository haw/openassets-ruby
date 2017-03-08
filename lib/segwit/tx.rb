# encoding: ascii-8bit

require 'bitcoin/script'

module Bitcoin
  module Protocol

    class Tx

      # witness (TxWitness)
      attr_reader :witness

      # create tx from raw binary +data+
      def initialize(data=nil)
        @ver, @lock_time, @in, @out, @scripts, @witness = 1, 0, [], [], [], TxWitness.new
        @enable_bitcoinconsensus = !!ENV['USE_BITCOINCONSENSUS']
        if data
          begin
            parse_witness_data_from_io(data) unless parse_data_from_io(data).is_a?(TrueClass)
          rescue Exception
            parse_witness_data_from_io(data)
          end
        end
      end

      # parse witness raw binary data
      # serialization format is defined by https://github.com/bitcoin/bips/blob/master/bip-0144.mediawiki
      def parse_witness_data_from_io(data)
        buf = data.is_a?(String) ? StringIO.new(data) : data

        @ver = buf.read(4).unpack("V").first

        @marker = buf.read(1).unpack("c").first

        @flag = buf.read(1).unpack("c").first

        in_size = Bitcoin::Protocol.unpack_var_int_from_io(buf)
        @in = []
        in_size.times{
          break if buf.eof?
          @in << Bitcoin::Protocol::TxIn.from_io(buf)
        }

        out_size = Bitcoin::Protocol.unpack_var_int_from_io(buf)
        @out = []
        out_size.times{
          break if buf.eof?
          @out << Bitcoin::Protocol::TxOut.from_io(buf)
        }

        @witness = Bitcoin::Protocol::TxWitness.new
        in_size.times{
          witness_count = Bitcoin::Protocol.unpack_var_int_from_io(buf)
          in_witness = Bitcoin::Protocol::TxInWitness.new
          witness_count.times{
            length = Bitcoin::Protocol.unpack_var_int_from_io(buf)
            in_witness.add_stack(buf.read(length).unpack("H*").first)
          }
          @witness.add_witness(in_witness)
        }

        @lock_time = buf.read(4).unpack("V").first

        @hash = hash_from_payload(to_payload)

        if buf.eof?
          true
        else
          data.is_a?(StringIO) ? buf : buf.read
        end
      end

      alias :parse_witness_data  :parse_witness_data_from_io

      # output transaction in raw binary format with witness
      def to_witness_payload
        pin = ""
        @in.each{|input| pin << input.to_payload }
        pout = ""
        @out.each{|output| pout << output.to_payload }
        [@ver].pack("V") << [0].pack("c") << [1].pack("c") << Bitcoin::Protocol.pack_var_int(@in.size) << pin <<
            Bitcoin::Protocol.pack_var_int(@out.size) << pout << @witness.to_payload << [@lock_time].pack("V")
      end

      # generate a witness signature hash for input +input_idx+.
      # https://github.com/bitcoin/bips/blob/master/bip-0143.mediawiki
      def signature_hash_for_witness_input(input_idx, witness_program, prev_out_value, witness_script = nil, hash_type=nil, skip_separator_index = 0)
        return "\x01".ljust(32, "\x00") if input_idx >= @in.size # ERROR: SignatureHash() : input_idx=%d out of range

        hash_type ||= SIGHASH_TYPE[:all]

        script = Bitcoin::Script.new(witness_program)
        raise "ScriptPubkey does not contain witness program." unless script.is_witness?

        hash_prevouts = Digest::SHA256.digest(Digest::SHA256.digest(@in.map{|i| [i.prev_out_hash, i.prev_out_index].pack("a32V")}.join))
        hash_sequence = Digest::SHA256.digest(Digest::SHA256.digest(@in.map{|i|i.sequence}.join))
        outpoint = [@in[input_idx].prev_out_hash, @in[input_idx].prev_out_index].pack("a32V")
        amount = [prev_out_value].pack("Q")
        nsequence = @in[input_idx].sequence

        if script.is_witness_v0_keyhash?
          script_code = [["1976a914", script.get_hash160, "88ac"].join].pack("H*")
        elsif script.is_witness_v0_scripthash?
          raise "witness script does not match script pubkey" unless Bitcoin::Script.to_witness_p2sh_script(Digest::SHA256.digest(witness_script).bth) == witness_program
          script = skip_separator_index > 0 ? Bitcoin::Script.new(witness_script).subscript_codeseparator(skip_separator_index) : witness_script
          script_code = Bitcoin::Protocol.pack_var_string(script)
        end

        hash_outputs = Digest::SHA256.digest(Digest::SHA256.digest(@out.map{|o|o.to_payload}.join))

        case (hash_type & 0x1f)
          when SIGHASH_TYPE[:single]
            hash_outputs = input_idx >= @out.size ? "\x00".ljust(32, "\x00") : Digest::SHA256.digest(Digest::SHA256.digest(@out[input_idx].to_payload))
            hash_sequence = "\x00".ljust(32, "\x00")
          when SIGHASH_TYPE[:none]
            hash_sequence = hash_outputs = "\x00".ljust(32, "\x00")
        end

        if (hash_type & SIGHASH_TYPE[:anyonecanpay]) != 0
          hash_prevouts = hash_sequence ="\x00".ljust(32, "\x00")
        end

        buf = [ [@ver].pack("V"), hash_prevouts, hash_sequence, outpoint,
                script_code, amount, nsequence, hash_outputs, [@lock_time, hash_type].pack("VV")].join

        Digest::SHA256.digest( Digest::SHA256.digest( buf ) )
      end

      # verify witness input signature +in_idx+ against the corresponding
      # output in +outpoint_tx+
      # outpoint
      #
      # options are: verify_sigpushonly, verify_minimaldata, verify_cleanstack, verify_dersig, verify_low_s, verify_strictenc
      def verify_witness_input_signature(in_idx, outpoint_tx_or_script, prev_out_amount, block_timestamp=Time.now.to_i, opts={})
        if @enable_bitcoinconsensus
          return bitcoinconsensus_verify_script(in_idx, outpoint_tx_or_script, block_timestamp, opts)
        end

        outpoint_idx  = @in[in_idx].prev_out_index
        script_sig    = ''

        # If given an entire previous transaction, take the script from it
        script_pubkey = if outpoint_tx_or_script.respond_to?(:out)
          Bitcoin::Script.new(outpoint_tx_or_script.out[outpoint_idx].pk_script)
        else
          # Otherwise, it's already a script.
          Bitcoin::Script.new(outpoint_tx_or_script)
        end

        if script_pubkey.is_p2sh?
          redeem_script = Bitcoin::Script.new(@in[in_idx].script_sig).get_pubkey
          script_pubkey = Bitcoin::Script.new(redeem_script.htb) if Bitcoin.hash160(redeem_script) == script_pubkey.get_hash160 # P2SH-P2WPKH or P2SH-P2WSH
        end

        witness.tx_in_wit[in_idx].stack.each{|s|script_sig << Bitcoin::Script.pack_pushdata(s.htb)}
        code_separator_index = 0

        if script_pubkey.is_witness_v0_keyhash? # P2WPKH
          @scripts[in_idx] = Bitcoin::Script.new(script_sig, Bitcoin::Script.to_hash160_script(script_pubkey.get_hash160))
        elsif script_pubkey.is_witness_v0_scripthash? # P2WSH
          witness_hex = witness.tx_in_wit[in_idx].stack.last
          witness_script = Bitcoin::Script.new(witness_hex.htb)
          return false unless Bitcoin.sha256(witness_hex) == script_pubkey.get_hash160
          @scripts[in_idx] = Bitcoin::Script.new(script_sig, Bitcoin::Script.to_p2sh_script(Bitcoin.hash160(witness_hex)))
        else
          return false
        end

        return false if opts[:verify_sigpushonly] && !@scripts[in_idx].is_push_only?(script_sig)
        return false if opts[:verify_minimaldata] && !@scripts[in_idx].pushes_are_canonical?
        sig_valid = @scripts[in_idx].run(block_timestamp, opts) do |pubkey,sig,hash_type,subscript|
          if script_pubkey.is_witness_v0_keyhash?
            hash = signature_hash_for_witness_input(in_idx, script_pubkey.to_payload, prev_out_amount, nil, hash_type)
          elsif script_pubkey.is_witness_v0_scripthash?
            hash = signature_hash_for_witness_input(in_idx, script_pubkey.to_payload, prev_out_amount, witness_hex.htb, hash_type, code_separator_index)
            code_separator_index += 1 if witness_script.codeseparator_count > code_separator_index
          end
          Bitcoin.verify_signature( hash, sig, pubkey.unpack("H*")[0] )
        end
        # BIP62 rule #6
        return false if opts[:verify_cleanstack] && !@scripts[in_idx].stack.empty?

        return sig_valid
      end

      # convert to ruby hash (see also #from_hash)
      def to_hash(options = {})
        @hash ||= hash_from_payload(to_payload)
        h = {
          'hash' => @hash, 'ver' => @ver, # 'nid' => normalized_hash,
          'vin_sz' => @in.size, 'vout_sz' => @out.size,
          'lock_time' => @lock_time, 'size' => (@payload ||= to_payload).bytesize,
          'in'  =>  @in.map.with_index{|i, index|
            h = i.to_hash(options)
            h.merge!('witness' => @witness.tx_in_wit[index].stack) if @witness.tx_in_wit[index]
            h
          },
          'out' => @out.map{|o| o.to_hash(options) }
        }
        h['nid'] = normalized_hash  if options[:with_nid]
        h
      end

      # parse ruby hash (see also #to_hash)
      def self.from_hash(h, do_raise=true)
        tx = new(nil)
        tx.ver, tx.lock_time = (h['ver'] || h['version']), h['lock_time']
        ins  = h['in']  || h['inputs']
        outs = h['out'] || h['outputs']
        ins .each{|input|
          tx.add_in(TxIn.from_hash(input))
          tx.witness.add_witness(TxInWitness.from_hash(input['witness'])) if input['witness']
        }
        outs.each{|output|  tx.add_out TxOut.from_hash(output) }
        tx.instance_eval{ @hash = hash_from_payload(@payload = to_payload) }
        if h['hash'] && (h['hash'] != tx.hash)
          raise "Tx hash mismatch! Claimed: #{h['hash']}, Actual: #{tx.hash}" if do_raise
        end
        tx
      end

      # convert ruby hash to raw binary
      def self.binary_from_hash(h)
        tx = from_hash(h)
        tx.witness.empty? ? tx.to_payload : tx.to_witness_payload
      end

      # get witness hash
      def witness_hash
        hash_from_payload(to_witness_payload)
      end

    end
  end
end
