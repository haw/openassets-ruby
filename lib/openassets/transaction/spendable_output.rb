module OpenAssets
  module Transaction

    # A transaction output with information about the asset ID and asset quantity associated to it.
    class SpendableOutput

      # An object that can be used to locate the output.
      attr_accessor :out_point
      # The actual output object.
      attr_accessor :output

      attr_accessor :confirmations

      # @param [OpenAssets::Transaction::OutPoint] out_point
      # @param [OpenAssets::Protocol::TransactionOutput] output
      def initialize(out_point, output)
        @out_point = out_point
        @output = output
      end

    end

  end
end