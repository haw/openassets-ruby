module OpenAssets
  module Transaction
    # An insufficient amount of assets is available.
    class InsufficientAssetQuantityError < TransactionBuildError
    end
  end
end