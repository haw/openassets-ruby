module OpenAssets
  module Util
    include ::Bitcoin::Util

    # namespace of Open Asset
    OA_NAMESPACE = 19

    # version byte for Open Assets Address
    OA_VERSION_BYTE = 23

    # convert bitcoin address to open assets address
    def address_to_oa_address(btc_address)
      btc_hex = decode_base58(btc_address)
      btc_hex = '0' +btc_hex if btc_hex.size==47
      address = btc_hex[0..-9] # bitcoin address without checksum
      named_addr = OA_NAMESPACE.to_s(16) + address
      oa_checksum = checksum(named_addr)
      encode_base58(named_addr + oa_checksum)
    end

    # generate asset ID from public key.
    def generate_asset_id(pub_key)
      hash = hash160(pub_key)
      # gen P2PKH script hash
      # P2PKH script = OP_DUP OP_HASH160 <PubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
      # （76=OP_DUP, a9=OP_HASH160, 14=Bytes to push, 88=OP_EQUALVERIFY, ac=OP_CHECKSIG）
      script = hash160(["76", "a9", "14", hash, "88", "ac"].join)
      script = OA_VERSION_BYTE.to_s(16) + script # add version byte to script hash
      encode_base58(script + checksum(script)) # add checksum & encode
    end

    # LEB128 encode
    def encode_leb128(value)
      d7=->n{(n>>7)==0 ? [n] : d7[n>>7]+[127 & n]}
      msb=->a{a0=a[0].to_s(16);[(a[0]< 16 ? "0"+a0 : a0)]+a[1..-1].map{|x|(x|128).to_s(16)}}
      leb128=->n{msb[d7[n]].reverse.join}
      leb128[value]
    end

  end
end