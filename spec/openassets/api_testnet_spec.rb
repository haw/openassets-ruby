require 'spec_helper'

describe OpenAssets::Api do

  include OpenAssets::Util

  context 'testnet', :network => :testnet do
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

    it 'multiple marker output exists in transaction' do
      outputs = subject.get_outputs_from_txid('9efbf61ef4805708ecf8e31d982ab6de20b2d131ed9be00d2856a5fe5a8b3df5')
      expect(outputs[1]['txid']).to eq('9efbf61ef4805708ecf8e31d982ab6de20b2d131ed9be00d2856a5fe5a8b3df5') # second marker output
      expect(outputs[1]['vout']).to eq(1)
      expect(outputs[1]['address']).to be nil
      expect(outputs[1]['oa_address']).to be nil
      expect(outputs[1]['script']).to eq('6a0a4f41010002c801e44b00')
      expect(outputs[1]['amount']).to eq('0.00000000')
      expect(outputs[1]['asset_id']).to eq('oK31ByjFuNhfnFuRMmZgchsdiprYmRzuz5')
      expect(outputs[1]['asset_quantity']).to eq('100')
      expect(outputs[2]['txid']).to eq('9efbf61ef4805708ecf8e31d982ab6de20b2d131ed9be00d2856a5fe5a8b3df5')
      expect(outputs[2]['vout']).to eq(2)
      expect(outputs[2]['address']).to eq('n3RKjN5TRcNeTzDvdaApME6KMchht2oMTU')
      expect(outputs[2]['oa_address']).to eq(address_to_oa_address('n3RKjN5TRcNeTzDvdaApME6KMchht2oMTU'))
      expect(outputs[2]['script']).to eq('76a914f0422a68ea970a9b007924bc8173f25e862eba8588ac')
      expect(outputs[2]['amount']).to eq('0.00000600')
      expect(outputs[2]['asset_id']).to eq('oK31ByjFuNhfnFuRMmZgchsdiprYmRzuz5')
      expect(outputs[2]['asset_quantity']).to eq('9800')
      expect(outputs[3]['txid']).to eq('9efbf61ef4805708ecf8e31d982ab6de20b2d131ed9be00d2856a5fe5a8b3df5')
      expect(outputs[3]['vout']).to eq(3)
      expect(outputs[3]['address']).to eq('mkgW6hNYBctmqDtTTsTJrsf2Gh2NPtoCU4')
      expect(outputs[3]['oa_address']).to eq(address_to_oa_address('mkgW6hNYBctmqDtTTsTJrsf2Gh2NPtoCU4'))
      expect(outputs[3]['script']).to eq('76a91438a6ebdf20cae2c9287ea014464042112ea3dbfd88ac')
      expect(outputs[3]['amount']).to eq('0.00000600')
      expect(outputs[3]['asset_id']).to be nil
      expect(outputs[3]['asset_quantity']).to eq('0')
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
    allow(btc_provider_mock).to receive(:get_transaction).with('9efbf61ef4805708ecf8e31d982ab6de20b2d131ed9be00d2856a5fe5a8b3df5', 0).and_return('0100000002bd2e17649e9e878aca0b13177dc8d8a64db56614a537a155f79f2251f0aaf62e020000006a473044022031443f89fc948371ea9081925a25b210097991b1e79daa238156ccf97215f0e1022017771ab41e42e7552afdc96a79928aed81e50c9245b644d867363a9e32e9a078012103e46fdcbf2062598a221c0e34d0505c270fb77c2c305c40ef0919f8efc0c7f959ffffffffbd2e17649e9e878aca0b13177dc8d8a64db56614a537a155f79f2251f0aaf62e030000006a4730440220152d9451f5087ab314ea97a5cfd3964b759e8e8c50fa0fc10e64787ad1860b6302206b3b004e0c2139bf767534fbff36fb205a6638ca141094f7a8ae95c5a32953aa012103e46fdcbf2062598a221c0e34d0505c270fb77c2c305c40ef0919f8efc0c7f959ffffffff0500000000000000000b6a094f4101000264c84c0000000000000000000c6a0a4f41010002c801e44b0058020000000000001976a914f0422a68ea970a9b007924bc8173f25e862eba8588ac58020000000000001976a91438a6ebdf20cae2c9287ea014464042112ea3dbfd88ace8240700000000001976a91438a6ebdf20cae2c9287ea014464042112ea3dbfd88ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('2ef6aaf051229ff755a137a51466b54da6d8c87d17130bca8a879e9e64172ebd', 0).and_return('0100000002dd6cee22d848a609df2d316112ca26b569c97c189400ad6f01046d65aa7b5f52000000006a473044022021806c9f0d888862cb6e8eb3952c48499fe4c0bedc4fb3ef20743c418109a23b02206249fceeeb4c2f496a3a48b57087f97e540af465f8b9328919f6f536ba5346ed012103e46fdcbf2062598a221c0e34d0505c270fb77c2c305c40ef0919f8efc0c7f959ffffffffdd6cee22d848a609df2d316112ca26b569c97c189400ad6f01046d65aa7b5f52020000006b483045022100981c9757ddf1280a47e9274fae9ff331a1a5b750c7f0c2a18de0b18413a3121e0220395d8baeb7802f9f3947152098442144946987d6be4065a0febe20bc20ca55df012103e46fdcbf2062598a221c0e34d0505c270fb77c2c305c40ef0919f8efc0c7f959ffffffff0400000000000000000b6a094f4101000263ac4d0058020000000000001976a914e9ac589641f17a2286631c24d6d2d00b8c959eb588ac58020000000000001976a91438a6ebdf20cae2c9287ea014464042112ea3dbfd88ac504e0700000000001976a91438a6ebdf20cae2c9287ea014464042112ea3dbfd88ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('525f7baa656d04016fad0094187cc969b526ca1261312ddf09a648d822ee6cdd', 0).and_return('010000000154f5a67cb14d7e50056f53263b72165daaf438164e7e825b862b9062a4e40612000000006b48304502210098e16e338e9600876e30d9dc0894bcd1bbb612431e7a36732c5feab0686d0641022044e7dcd512073f31d0c67e0fbbf2269c4a31d5bf3bb1fcc8fbdd2e4d3c0d7e58012103e46fdcbf2062598a221c0e34d0505c270fb77c2c305c40ef0919f8efc0c7f959ffffffff0358020000000000001976a91438a6ebdf20cae2c9287ea014464042112ea3dbfd88ac0000000000000000216a1f4f410100018f4e17753d68747470733a2f2f676f6f2e676c2f755667737434b8770700000000001976a91438a6ebdf20cae2c9287ea014464042112ea3dbfd88ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('1206e4a462902b865b827e4e1638f4aa5d16723b26536f05507e4db17ca6f554', 0).and_return('0100000001e065787fe31b0f87a1e7fc3d36915bd2048c40e12198d3dfcdb01824953c8cf8010000006b483045022100a6752e02271f668aa0d72eabb2132738816b35d15cae5d5d293b32b0e5d22bf102202d653d019ec10aa3eef5be4cc2488908352b47beea91cb18465b16edcae4e2cf01210316cff587a01a2736d5e12e53551b18d73780b83c3bfb4fcf209c869b11b6415effffffff0220a10700000000001976a91438a6ebdf20cae2c9287ea014464042112ea3dbfd88acbc371004000000001976a914c01a7ca16b47be50cbdbc60724f701d52d75156688ac00000000')

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