module OpenAssets
  module Transaction

    # The combination of a transaction hash and an index n into its vout
    class OutPoint

      attr_accessor :hash
      attr_accessor :index

      # @param [String] hash: 32 bytes transaction hash in vout.
      # @param [Integer] index: index in vout.
      def initialize(hash, index)
        raise ArgumentError, 'hash must be exactly 32 bytes.' unless [hash].pack("H*").bytesize == 32
        raise ArgumentError, 'index must be in range 0x0 to 0xffffffff.' unless index.between?(0x0, 0xffffffff)
        @hash = hash
        @index = index
      end

    end

  end
end