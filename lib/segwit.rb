# This is a temporary implementation until bitcoin-ruby formally supports Segregated Witness.
# This implementation ported from the implementation of the pull request below.
# https://github.com/lian/bitcoin-ruby/pull/203
module Bitcoin
  module Protocol
    require 'segwit/tx'
    require 'segwit/script'
    autoload :TxWitness, 'segwit/tx_witness'
    autoload :TxInWitness, 'segwit/tx_in_witness'
    autoload :ScriptWitness, 'segwit/script_witness'
  end
end