module OpenAssets

    class SendAssetParam
      attr_accessor :asset_id
      attr_accessor :amount
      attr_accessor :to

      def initialize(asset_id, amount, to)
        @asset_id = asset_id
        @amount = amount
        @to = to
      end
    end

end