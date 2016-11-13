module Bitcoin
  module Protocol
    require 'segwit/tx'
    require 'segwit/script'
    autoload :TxWitness, 'segwit/tx_witness'
    autoload :TxInWitness, 'segwit/tx_in_witness'
    autoload :ScriptWitness, 'segwit/script_witness'
  end
end