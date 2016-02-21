module OpenAssets
  module Cache
    autoload :SQLiteBase, 'openassets/cache/sqlite_base'
    autoload :TransactionCache, 'openassets/cache/transaction_cache'
    autoload :SSLCertificateCache, 'openassets/cache/ssl_certificate_cache'
  end
end