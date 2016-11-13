module SegwitScript

  # override Bitcoin::Script#is_standard?
  # Add P2WPKH and P2WSH to the standard
  def is_standard?
    super || is_witness_v0_keyhash? || is_witness_v0_scripthash?
  end

  # see https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki#Witness_program
  def is_witness_v0_keyhash?
    @chunks.length == 2 &&@chunks[0] == 0 && @chunks[1].bytesize == 20
  end

  # see https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki#Witness_program
  def is_witness_v0_scripthash?
    @chunks.length == 2 &&@chunks[0] == 0 && @chunks[1].bytesize == 32
  end

  # override Bitcoin::Script#type
  # Add type witness_v0_keyhash and witness_v0_scripthash
  def type
    base = super
    if base == :unknown
      return :witness_v0_keyhash if is_witness_v0_keyhash?
      return :witness_v0_scripthash if is_witness_v0_scripthash?
      :unknown
    end
  end
end

class Bitcoin::Script
  prepend SegwitScript
end
