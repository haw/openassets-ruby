require 'sqlite3'
module OpenAssets
  module Cache

    # An object that can be used for caching serialized transaction in a Sqlite database.
    class TransactionCache

      attr_reader :db

      # Initializes the connection to the database, and creates the table if needed.
      # @param[String] path The path to the database file. Use ':memory:' for an in-memory database.
      def initialize(path)
        @db = SQLite3::Database.new path
        @db.execute <<-SQL
          CREATE TABLE IF NOT EXISTS Tx(
                  TransactionHash BLOB,
                  SerializedTx BLOB,
                  PRIMARY KEY (TransactionHash))
        SQL
      end

      # Return the serialized transaction.
      # @param[String] txid The transaction id.
      # @return[String] The serialized transaction. If not found transaction, return nil.
      def get(txid)
        rows = db.execute('SELECT SerializedTx FROM Tx WHERE TransactionHash = ?', [txid])
        rows.empty? ? nil : rows[0][0]
      end

      # Saves a serialized transaction in cache.
      # @param[String] txid A transaction id.
      # @param[String] serialized_tx A a hex-encoded serialized transaction.
      def put(txid, serialized_tx)
        db.execute('INSERT INTO Tx (TransactionHash, SerializedTx) VALUES (?, ?)', [txid, serialized_tx])
      end
    end

  end
end