require 'spec_helper'

describe OpenAssets::Api do

  include OpenAssets::Util

  context 'testnet', :network => 'testnet' do
    subject {
      testnet_mock = double('BitcoinCoreProviderTestnet Mock')
      api = OpenAssets::Api.new
      api.config[:network] = 'testnet'
      allow(testnet_mock).to receive(:list_unspent).and_return(TESTNET_BTC_UNSPENT)
      setup_tx_load_mock(testnet_mock)
      allow(api).to receive(:provider).and_return(testnet_mock)
      api
    }

    it 'list_unspent' do
      list = subject.list_unspent
      expect(list[0]['txid']).to eq('e1dcdb553d40ec35aac0a5b9bc2cce0112dd10c869a887b52b3b58071bb29f3c')
      expect(list[0]['asset_id']).to eq('oWLkUn44E45cnQtsP6x1wrvJ2iRx9XyFny')
      expect(list[0]['script']).to eq('76a9148130f96080e598cc4e210067eb54403074aa1a8d88ac')
      expect(list[0]['amount']).to eq('0.00000600')
      expect(list[0]['confirmations']).to eq(1)
      expect(list[0]['oa_address']).to eq('bX3FwNkYLUkW1n9CoMhtnjDHrBy96Dgz2gG')
      expect(list[0]['address']).to eq('msJ48aj11GcKuu3SK5nc5MPGrMxvE1oR5Y')
      expect(list[0]['asset_quantity']).to eq("547")
      expect(list[0]['asset_amount']).to eq("547")
      expect(list[0]['account']).to eq('')
    end

    it 'get_balance' do
      balances = subject.get_balance
      expect(balances[0]['value']).to eq('0.00000600')
      expect(balances[0]['oa_address']).to eq('bX3FwNkYLUkW1n9CoMhtnjDHrBy96Dgz2gG')
      expect(balances[0]['address']).to eq('msJ48aj11GcKuu3SK5nc5MPGrMxvE1oR5Y')
      assets = balances[0]['assets']
      expect(assets[0]['asset_id']).to eq("oWLkUn44E45cnQtsP6x1wrvJ2iRx9XyFny")
      expect(assets[0]['quantity']).to eq("547")
      expect(balances[0]['account']).to eq('')
    end
  end

  def filter_btc_unspent(btc_address = nil)
    return TESTNET_BTC_UNSPENT if btc_address.nil?
    TESTNET_BTC_UNSPENT.select{|u|u['address'] == btc_address}
  end

  def get_account(btc_address)
    TESTNET_BTC_UNSPENT.select{|u|u['address'] == btc_address}.first['account']
  end

  def setup_tx_load_mock(btc_provider_mock)
    allow(btc_provider_mock).to receive(:get_transaction).with('e1dcdb553d40ec35aac0a5b9bc2cce0112dd10c869a887b52b3b58071bb29f3c', 0).and_return('01000000016475d1c8e6d8c289191fe5810801c0285c3fef9d82dbe9da01b344ac446ef308000000006a473044022078405f742167e0e79cd371cc7618006b274ee37dc61182d7a925492a2b3bf684022009646930834c0d017059c7bfcfc4b0c79ae47548c64f3dcfe8375d6a81506d23012102bf9ae6b35ee08f18e4ff7a28cefcef511142e6169086579b8d468097327780ebffffffff0458020000000000001976a9148130f96080e598cc4e210067eb54403074aa1a8d88ac00000000000000000a6a084f41010001a30400fd905c05000000001976a914626871f87bfb20804d5b2ae2cde668efd70c60d388ac1b900000000000001976a9148130f96080e598cc4e210067eb54403074aa1a8d88ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('08f36e44ac44b301dae9db829def3f5c28c0010881e51f1989c2d8e6c8d17564', 0).and_return('010000000186ef064c5f594cf1d7e38945a90ad2a8f8b591d68c7be489b3f4a498710cd8e8000000006a47304402207fb3b248528e525574f5144a3ae555f02178cc2636867eed336f93befc8ca1f202201267600dd0141217bd3d09821ec0b13f5a50139944813449fcd6f3ef330e6737012103f5eb09ef185377397cfe73eaea491602b84b5cb55ea4469a930d09f20d13e1deffffffff02804a5d05000000001976a914081522820f2ccef873e47ee62b31cb9e9267e72588ac706f9800000000001976a9148130f96080e598cc4e210067eb54403074aa1a8d88ac00000000')

  end

  TESTNET_BTC_UNSPENT = [
      {"txid" => "e1dcdb553d40ec35aac0a5b9bc2cce0112dd10c869a887b52b3b58071bb29f3c",
       "vout" => 0,
       "address" => "msJ48aj11GcKuu3SK5nc5MPGrMxvE1oR5Y",
       "account" => "",
       "scriptPubKey" => "76a9148130f96080e598cc4e210067eb54403074aa1a8d88ac",
       "amount" => 0.00000600,
       "confirmations" => 1,
       "spendable" => true
      }
  ]

end