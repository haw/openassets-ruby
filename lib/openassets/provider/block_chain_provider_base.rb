module OpenAssets
  module Provider

    # The base class providing access to the Blockchain.
    class BlockChainProviderBase

      def list_unspent
        raise NotImplementedError
      end

    end

  end
end