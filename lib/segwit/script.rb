# encoding: ascii-8bit

require 'bitcoin'

class Bitcoin::Script
  # Returns a script that deleted the script before the index specified by separator_index.
  def subscript_codeseparator(separator_index)
    buf = []
    process_separator_index = 0
    (chunks || @chunks).each{|chunk|
      buf << chunk if process_separator_index == separator_index
      process_separator_index += 1 if chunk == OP_CODESEPARATOR and process_separator_index < separator_index
    }
    to_binary(buf)
  end

  # check if script is in one of the recognized standard formats
  def is_standard?
    is_pubkey? || is_hash160? || is_multisig? || is_p2sh?  || is_op_return? || is_witness_v0_keyhash? || is_witness_v0_scripthash?
  end

  # is this a witness script(witness_v0_keyhash or witness_v0_scripthash)
  def is_witness?
    is_witness_v0_keyhash? || is_witness_v0_scripthash?
  end

  # is this a witness pubkey script
  def is_witness_v0_keyhash?
    @chunks.length == 2 &&@chunks[0] == 0 && @chunks[1].is_a?(String) && @chunks[1].bytesize == 20
  end

  # is this a witness script hash
  def is_witness_v0_scripthash?
    @chunks.length == 2 &&@chunks[0] == 0 && @chunks[1].is_a?(String) && @chunks[1].bytesize == 32
  end

  # get type of this tx
  def type
    if is_hash160?;                 :hash160
    elsif is_pubkey?;               :pubkey
    elsif is_multisig?;             :multisig
    elsif is_p2sh?;                 :p2sh
    elsif is_op_return?;            :op_return
    elsif is_witness_v0_keyhash?;   :witness_v0_keyhash
    elsif is_witness_v0_scripthash?;:witness_v0_scripthash
    else;                           :unknown
    end
  end

  # get the hash160 for this hash160 or pubkey script
  def get_hash160
    return @chunks[2..-3][0].unpack("H*")[0]  if is_hash160?
    return @chunks[-2].unpack("H*")[0]        if is_p2sh?
    return Bitcoin.hash160(get_pubkey)        if is_pubkey?
    return @chunks[1].unpack("H*")[0]         if is_witness_v0_keyhash?
    return @chunks[1].unpack("H*")[0]         if is_witness_v0_scripthash?
  end

  # generate p2wpkh tx for given +address+. returns a raw binary script of the form:
  # 0 <hash160>
  def self.to_witness_hash160_script(hash160)
    return nil  unless hash160
    #  witness ver  length  hash160
    [ ["00",         "14",  hash160].join ].pack("H*")
  end

  # generate p2wsh output script for given +p2sh+ sha256. returns a raw binary script of the form:
  # 0 <p2sh>
  def self.to_witness_p2sh_script(p2sh)
    return nil  unless p2sh
    #  witness ver  length  sha256
    [ [ "00",        "20",   p2sh].join].pack("H*")
  end

  def codeseparator_count
    @chunks.select{|c|c == Bitcoin::Script::OP_CODESEPARATOR}.length
  end
end
