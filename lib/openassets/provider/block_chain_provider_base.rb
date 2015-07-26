module OpenAssets
  module Provider

    # The base class providing access to the Blockchain.
    class BlockChainProviderBase

      def list_unspent(addresses = [], min = 1 , max = 9999999)
        raise NotImplementedError
      end

      def get_transaction(transaction_hash, verbose = 0)
        raise NotImplementedError
      end

      def sign_transaction(tx)
        raise NotImplementedError
      end

    end

  end
end