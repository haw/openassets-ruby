require 'bigdecimal'
module OpenAssets
  module Util
    extend ::Bitcoin::Util
    include ::Bitcoin::Util

    # namespace of Open Asset
    OA_NAMESPACE = 19

    # version byte for Open Assets Address
    OA_VERSION_BYTE = 23
    OA_VERSION_BYTE_TESTNET = 115

    # convert bitcoin address to open assets address
    # @param [String] btc_address The Bitcoin address.
    # @return [String] The Open Assets Address.
    def address_to_oa_address(btc_address)
      begin
        btc_hex = decode_base58(btc_address)
        btc_hex = '0' +btc_hex if btc_hex.size==47
        address = btc_hex[0..-9] # bitcoin address without checksum
        named_addr = OA_NAMESPACE.to_s(16) + address
        oa_checksum = checksum(named_addr)
        encode_base58(named_addr + oa_checksum)
      rescue ArgumentError
        nil # bech32 format fails to decode. TODO define OA address for segwit
      end
    end

    # convert open assets address to bitcoin address
    # @param [String] oa_address The Open Assets Address.
    # @return [String] The Bitcoin address.
    def oa_address_to_address(oa_address)
      decode_address = decode_base58(oa_address)
      btc_addr = decode_address[2..-9]
      btc_checksum = checksum(btc_addr)
      encode_base58(btc_addr + btc_checksum)
    end

    # generate asset ID from public key.
    def generate_asset_id(pub_key)
      pubkey_hash_to_asset_id(hash160(pub_key))
    end

    def pubkey_hash_to_asset_id(pubkey_hash)
      # gen P2PKH script hash
      # P2PKH script = OP_DUP OP_HASH160 <PubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
      # （76=OP_DUP, a9=OP_HASH160, 14=Bytes to push, 88=OP_EQUALVERIFY, ac=OP_CHECKSIG）
      hash_to_asset_id(hash160(["76", "a9", "14", pubkey_hash, "88", "ac"].join))
    end

    def script_to_asset_id(script)
      hash_to_asset_id(hash160(script))
    end

    def hash_to_asset_id(hash)
      hash = oa_version_byte.to_s(16) + hash # add version byte to script hash
      encode_base58(hash + checksum(hash)) # add checksum & encode
    end

    # LEB128 encode
    def encode_leb128(value)
      LEB128.encode_unsigned(value).read.bth
    end

    # LEB128 decode
    def decode_leb128(value)
      results = []
      sio = StringIO.new
      value.htb.each_byte{|b|
        sio.putc(b)
        if b < 128
          results << LEB128.decode_unsigned(sio)
          sio = StringIO.new
        end
      }
      results
    end

    def to_bytes(string)
      string.each_char.each_slice(2).map{|v|v.join}
    end

    # Convert satoshi to coin.
    # @param [Integer] satoshi The amount of satoshi unit.
    # @return [String] The amount of coin.
    def satoshi_to_coin(satoshi)
      "%.8f" % (satoshi / 100000000.0)
    end

    # Convert coin unit to satoshi.
    # @param [String] coin The amount of bitcoin
    # @return [String] The amount of satoshi.
    def coin_to_satoshi(coin)
      BigDecimal(coin) * BigDecimal(100000000)
    end

    # Get address from script.
    # @param [Bitcoin::Script] script The output script.
    # @return [String] The Bitcoin address. if the script dose not contains address, return nil.
    def script_to_address(script)
      script.is_multisig? ? script.get_multisig_addresses : script.get_addresses.first
    end

    # validate bitcoin address
    def validate_address(addresses)
      addresses.each{|a|
        raise ArgumentError, "#{a} is invalid bitcoin address. " unless valid_address?(a)
      }
    end

    # validate asset ID
    def valid_asset_id?(asset_id)
      return false if asset_id.nil? || asset_id.length != 34
      decoded = decode_base58(asset_id)
      return false if  decoded[0,2].to_i(16) != oa_version_byte
      p2pkh_script_hash = decoded[2..-9]
      address = hash160_to_address(p2pkh_script_hash)
      valid_address?(address)
    end

    # read variable integer
    # @param [String] data reading data
    # @param [Integer] offset the position when reading from data.
    # @return [[Integer, Integer]]  decoded integer value and the reading byte length.
    # https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer
    def read_var_integer(data, offset = 0)
      raise ArgumentError, "data is nil." unless data
      packed = [data].pack('H*')
      return [nil, 0] if packed.bytesize < 1+offset
      bytes = packed.bytes[offset..(offset + 9)] # 9 is variable integer max storage length.
      first_byte = bytes[0]
      if first_byte < 0xfd
        [first_byte, offset + 1]
      elsif first_byte == 0xfd
        [calc_var_integer_val(bytes[1..2]), offset + 3]
      elsif first_byte == 0xfe
        [calc_var_integer_val(bytes[1..4]), offset + 5]
      elsif first_byte == 0xff
        [calc_var_integer_val(bytes[1..8]), offset + 9]
      end
    end

    # read leb128 value
    # @param [String] data reading data
    # @param [Integer] offset start position when reading from data.
    # @return [[Integer, Integer]]  decoded integer value and the reading byte length.
    def read_leb128(data, offset = 0)
      bytes = [data].pack('H*').bytes
      result = 0
      shift = 0
      while true
        return [nil, offset] if bytes.length < 1 + offset
        byte = bytes[offset..(offset + 1)][0]
        result |= (byte & 0x7f) << shift
        break if byte & 0x80 == 0
        shift += 7
        offset += 1
      end
      [result, offset + 1]
    end

    private
    def oa_version_byte
      Bitcoin.network[:address_version] == "6f" ? OA_VERSION_BYTE_TESTNET : OA_VERSION_BYTE
    end

    def calc_var_integer_val(byte_array)
      byte_array.each_with_index.inject(0){|sum, pair| pair[1] == 0 ? pair[0] : sum + pair[0]*(256**pair[1])}
    end
    
  end
end