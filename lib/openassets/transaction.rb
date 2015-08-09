module OpenAssets
  module Transaction
    autoload :TransactionBuilder, 'openassets/transaction/transaction_builder'
    autoload :TransferParameters, 'openassets/transaction/transfer_parameters'
    autoload :SpendableOutput, 'openassets/transaction/spendable_output'
    autoload :OutPoint, 'openassets/transaction/out_point'
    autoload :TransactionBuildError, 'openassets/transaction/transaction_build_error'
    autoload :InsufficientFundsError, 'openassets/transaction/insufficient_funds_error'
    autoload :InsufficientAssetQuantityError, 'openassets/transaction/insufficient_asset_quantity_error'
    autoload :DustOutputError, 'openassets/transaction/dust_output_error'
  end
end