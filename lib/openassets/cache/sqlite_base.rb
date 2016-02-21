require 'sqlite3'

module OpenAssets
  module Cache

    # The base class of SQLite3 cache implementation.
    class SQLiteBase

      attr_reader :db

      # Initializes the connection to the database, and creates the table if needed.
      # @param[String] path The path to the database file. Use ':memory:' for an in-memory database.
      def initialize(path)
        @db = SQLite3::Database.new path
        setup
      end

      # Setup table ddl, implements by subclass.
      def setup
        raise StandardError.new('need setup method implementation.')
      end

    end

  end
end