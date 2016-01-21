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
      btc_hex = decode_base58(btc_address)
      btc_hex = '0' +btc_hex if btc_hex.size==47
      address = btc_hex[0..-9] # bitcoin address without checksum
      named_addr = OA_NAMESPACE.to_s(16) + address
      oa_checksum = checksum(named_addr)
      encode_base58(named_addr + oa_checksum)
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

    def pubkey_hash_to_asset_id(hash)
      # gen P2PKH script hash
      # P2PKH script = OP_DUP OP_HASH160 <PubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
      # （76=OP_DUP, a9=OP_HASH160, 14=Bytes to push, 88=OP_EQUALVERIFY, ac=OP_CHECKSIG）
      script = hash160(["76", "a9", "14", hash, "88", "ac"].join)
      script = oa_version_byte.to_s(16) + script # add version byte to script hash
      encode_base58(script + checksum(script)) # add checksum & encode
    end

    # LEB128 encode
    def encode_leb128(value)
      d7=->n{(n>>7)==0 ? [n] : d7[n>>7]+[127 & n]}
      msb=->a{a0=a[0].to_s(16);[(a[0]< 16 ? "0"+a0 : a0)]+a[1..-1].map{|x|(x|128).to_s(16)}}
      leb128=->n{msb[d7[n]].reverse.join}
      leb128[value]
    end

    # LEB128 decode
    def decode_leb128(value)
      mbs = to_bytes(value).map{|x|(x.to_i(16)>=128 ? x : x+"|")}.join.split('|')
      num=->a{(a.size==1 ? a[0] : (num[a[0..-2]]<<7)|a[-1])}
      r7=->n{to_bytes(n).map{|x|(x.to_i(16))&127}}
      mbs.map{|x|num[r7[x].reverse]}
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

    # Get address from script.
    # @param [Bitcoin::Script] script The output script.
    # @return [String] The Bitcoin address. if the script dose not contains address, return nil.
    def script_to_address(script)
      return script.get_pubkey_address    if script.is_pubkey?
      return script.get_hash160_address   if script.is_hash160?
      return script.get_multisig_addresses  if script.is_multisig?
      return script.get_p2sh_address      if script.is_p2sh?
      nil
    end

    # validate bitcoin address
    def validate_address(addresses)
      addresses.each{|a|
        raise ArgumentError, "#{a} is invalid bitcoin address. " unless valid_address?(a)
      }
    end

    # generate Asset ID from open asset address.
    def oa_address_to_asset_id(oa_address)
      address_to_asset_id(oa_address_to_address(oa_address))
    end

    # generate Asset ID from bitcoin address.
    def address_to_asset_id(btc_address)
      pubkey_hash = hash160_from_address(btc_address)
      pubkey_hash_to_asset_id(pubkey_hash)
    end

    private
    def oa_version_byte
      Bitcoin.network[:address_version] == "6f" ? OA_VERSION_BYTE_TESTNET : OA_VERSION_BYTE
    end
  end
end