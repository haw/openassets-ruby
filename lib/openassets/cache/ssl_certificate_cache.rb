module OpenAssets
  module Cache
    class SSLCertificateCache < SQLiteBase

      def initialize
        path = OpenAssets.configuration ? OpenAssets.configuration[:cache] : ':memory:'
        super(path)
      end

      def setup
        db.execute <<-SQL
          CREATE TABLE IF NOT EXISTS SslCertificate(
                  Url TEXT,
                  Subject TEXT,
                  ExpireDate TEXT,
                  PRIMARY KEY (Url))
        SQL
      end

      # Return the subject value which defined by ssl certificate.
      # @param[String] url The URL of asset definition file.
      # @return[String] The subject value. If not found, return nil.
      def get(url)
        rows = db.execute('SELECT Subject,ExpireDate FROM SslCertificate WHERE Url = ?', [url])
        return nil if rows.empty?
        if rows[0][1].to_i < Time.now.to_i
          db.execute('DELETE FROM SslCertificate where Url = ?', [url])
          nil
        else
          rows[0][0]
        end
      end

      # Saves a serialized transaction in cache.
      # @param[String] url The URL of asset definition file.
      # @param[String] subject The SSL Certificate subject value.
      # @param[Time] expire_date The expire date of SSL Certificate.
      def put(url, subject, expire_date)
        db.execute('INSERT INTO SslCertificate (Url, Subject, ExpireDate) VALUES (?, ?, ?)', [url, subject, expire_date.to_i])
      end

    end
  end
end