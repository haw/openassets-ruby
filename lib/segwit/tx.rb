# extension for Bitcoin::Protocol::Tx to support segwit
class Bitcoin::Protocol::Tx
  include Bitcoin::Util

  attr_reader :witness

  def initialize(data=nil)
    @ver, @lock_time, @in, @out, @scripts, @witness = 1, 0, [], [], [], Bitcoin::Protocol::TxWitness.new
    @enable_bitcoinconsensus = !!ENV['USE_BITCOINCONSENSUS']
    if data
      if witness_tx?(data)
        parse_witness_data_from_io(data) # parse witness data
      else
        parse_data_from_io(data) # parse no witness data
      end
    end
  end

  # get witness hash
  def witness_hash
    hash_from_payload(to_witness_payload)
  end

  # parse raw data which include witness data
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
  end

  # output transaction in raw binary format with witness
  def to_witness_payload
    pin = ""
    @in.each{|input| pin << input.to_payload }
    pout = ""
    @out.each{|output| pout << output.to_payload }
    payload = [@ver].pack("V") << [0].pack("c") << [1].pack("c") << Bitcoin::Protocol.pack_var_int(@in.size) << pin <<
        Bitcoin::Protocol.pack_var_int(@out.size) << pout << @witness.to_payload << [@lock_time].pack("V")
    payload
  end

  # Checks witness transaction data.
  # see https://github.com/bitcoin/bips/blob/master/bip-0144.mediawiki
  def witness_tx?(data)
    buf = data.is_a?(String) ? StringIO.new(data) : data
    buf.read(4) # read nVersion
    marker = buf.read(1).unpack("c").first
    flag = buf.read(1).unpack("c").first
    marker == 0 && flag == 1
  end

end