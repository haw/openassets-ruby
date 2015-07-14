module OpenAssets
  module Transaction

    # The value of an output would be too small, and the output would be considered as dust.
    class DustOutputError < TransactionBuildError

    end

  end
end