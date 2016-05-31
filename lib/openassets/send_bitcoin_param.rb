module OpenAssets

    class SendBitcoinParam
      attr_accessor :amount
      attr_accessor :to

      def initialize(amount, to)
        @amount = amount
        @to = to
      end
    end

end