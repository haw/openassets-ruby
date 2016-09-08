module OpenAssets
  module Protocol
    autoload :MarkerOutput, 'openassets/protocol/marker_output'
    autoload :TransactionOutput, 'openassets/protocol/transaction_output'
    autoload :OutputType, 'openassets/protocol/output_type'
    autoload :AssetDefinitionLoader, 'openassets/protocol/asset_definition_loader'
    autoload :HttpAssetDefinitionLoader, 'openassets/protocol/http_asset_definition_loader'
    autoload :AssetDefinition, 'openassets/protocol/asset_definition'
  end
end