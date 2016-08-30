module OpenAssets

    class SendAssetParam
      attr_accessor :asset_id
      attr_accessor :amount
      attr_accessor :to
      attr_accessor :from

      def initialize(asset_id, amount, to, from = nil)
        @asset_id = asset_id
        @amount = amount
        @to = to
        @from = from
      end
    end

end