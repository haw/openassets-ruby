module OpenAssets
  module Util
    include ::Bitcoin::Util

    # namespace fo Open Asset
    OA_NAMESPACE = 19

    # convert bitcoin address to open assets address
    def address_to_oa_address(btc_address)
      btc_hex = decode_base58(btc_address)
      btc_hex = '0' +btc_hex if btc_hex.size==47
      address = btc_hex[0..-9] # checksumを除いたBitcoin Address
      named_addr = OA_NAMESPACE.to_s(16) + address
      oa_checksum = checksum(named_addr)
      encode_base58(named_addr + oa_checksum)
    end

  end
end