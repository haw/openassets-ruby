require 'spec_helper'

describe OpenAssets::Api, :network => :testnet do

  include OpenAssets::Util
  extend OpenAssets::Util

  context 'testnet' do

    describe 'list_unspent' do
      subject{
        create_api.list_unspent
      }
      it do
        expect(subject[0]['txid']).to eq('e1dcdb553d40ec35aac0a5b9bc2cce0112dd10c869a887b52b3b58071bb29f3c')
        expect(subject[0]['asset_id']).to eq('oWLkUn44E45cnQtsP6x1wrvJ2iRx9XyFny')
        expect(subject[0]['script']).to eq('76a9148130f96080e598cc4e210067eb54403074aa1a8d88ac')
        expect(subject[0]['amount']).to eq('0.00000600')
        expect(subject[0]['confirmations']).to eq(1)
        expect(subject[0]['oa_address']).to eq('bX3FwNkYLUkW1n9CoMhtnjDHrBy96Dgz2gG')
        expect(subject[0]['address']).to eq('msJ48aj11GcKuu3SK5nc5MPGrMxvE1oR5Y')
        expect(subject[0]['asset_quantity']).to eq('547')
        expect(subject[0]['asset_amount']).to eq('547')
        expect(subject[0]['account']).to eq('')
        expect(subject[0]['proof_of_authenticity']).to eq(false)
        expect(subject[0]['spendable']).to eq(true)
        expect(subject[0]['solvable']).to eq(true)

        expect(subject[7]['asset_id']).to eq('oNJgtrSSRzsU9k8Gnozy8pARhrwjKRoX5m')
        expect(subject[7]['proof_of_authenticity']).to eq(true)
      end
    end

    describe 'get_balance' do
      context 'disable authenticity' do
        subject{
          create_api.get_balance('bX3FwNkYLUkW1n9CoMhtnjDHrBy96Dgz2gG')
        }
        it do
          expect(subject[0]['value']).to eq('0.00000600')
          expect(subject[0]['oa_address']).to eq('bX3FwNkYLUkW1n9CoMhtnjDHrBy96Dgz2gG')
          expect(subject[0]['address']).to eq('msJ48aj11GcKuu3SK5nc5MPGrMxvE1oR5Y')
          assets = subject[0]['assets']
          expect(assets[0]['asset_id']).to eq('oWLkUn44E45cnQtsP6x1wrvJ2iRx9XyFny')
          expect(assets[0]['quantity']).to eq('547')
          expect(assets[0]['proof_of_authenticity']).to eq(false)
          expect(subject[0]['account']).to eq('')
        end
      end

      context 'enable authenticity' do
        subject{
          create_api.get_balance('bWsM93ZHn89GByRWrBDoWhFUeBMZEt9mFcT')[0]['assets']
        }
        it do
          expect(subject[0]['asset_id']).to eq('oNJgtrSSRzsU9k8Gnozy8pARhrwjKRoX5m')
          expect(subject[0]['quantity']).to eq('777')
          expect(subject[0]['proof_of_authenticity']).to eq(true)
        end
      end
    end

    describe 'get_outputs_from_txid' do
      subject{
        create_api.get_outputs_from_txid('9efbf61ef4805708ecf8e31d982ab6de20b2d131ed9be00d2856a5fe5a8b3df5')
      }
      it do
        expect(subject[0]['output_type']).to eq('marker')

        expect(subject[1]['txid']).to eq('9efbf61ef4805708ecf8e31d982ab6de20b2d131ed9be00d2856a5fe5a8b3df5') # second marker output
        expect(subject[1]['vout']).to eq(1)
        expect(subject[1]['address']).to be nil
        expect(subject[1]['oa_address']).to be nil
        expect(subject[1]['script']).to eq('6a0a4f41010002c801e44b00')
        expect(subject[1]['amount']).to eq('0.00000000')
        expect(subject[1]['asset_id']).to be nil
        expect(subject[1]['asset_quantity']).to eq('0')
        expect(subject[1]['output_type']).to eq('marker')

        expect(subject[2]['txid']).to eq('9efbf61ef4805708ecf8e31d982ab6de20b2d131ed9be00d2856a5fe5a8b3df5')
        expect(subject[2]['vout']).to eq(2)
        expect(subject[2]['address']).to eq('n3RKjN5TRcNeTzDvdaApME6KMchht2oMTU')
        expect(subject[2]['oa_address']).to eq(address_to_oa_address('n3RKjN5TRcNeTzDvdaApME6KMchht2oMTU'))
        expect(subject[2]['script']).to eq('76a914f0422a68ea970a9b007924bc8173f25e862eba8588ac')
        expect(subject[2]['amount']).to eq('0.00000600')
        expect(subject[2]['asset_id']).to eq('oK31ByjFuNhfnFuRMmZgchsdiprYmRzuz5')
        expect(subject[2]['asset_quantity']).to eq('100')
        expect(subject[2]['output_type']).to eq('transfer')

        expect(subject[3]['txid']).to eq('9efbf61ef4805708ecf8e31d982ab6de20b2d131ed9be00d2856a5fe5a8b3df5')
        expect(subject[3]['vout']).to eq(3)
        expect(subject[3]['address']).to eq('mkgW6hNYBctmqDtTTsTJrsf2Gh2NPtoCU4')
        expect(subject[3]['oa_address']).to eq(address_to_oa_address('mkgW6hNYBctmqDtTTsTJrsf2Gh2NPtoCU4'))
        expect(subject[3]['script']).to eq('76a91438a6ebdf20cae2c9287ea014464042112ea3dbfd88ac')
        expect(subject[3]['amount']).to eq('0.00000600')
        expect(subject[3]['asset_id']).to eq('oK31ByjFuNhfnFuRMmZgchsdiprYmRzuz5')
        expect(subject[3]['asset_quantity']).to eq('9800')
        expect(subject[3]['output_type']).to eq('transfer')

        expect(subject[4]['txid']).to eq('9efbf61ef4805708ecf8e31d982ab6de20b2d131ed9be00d2856a5fe5a8b3df5')
        expect(subject[4]['vout']).to eq(4)
        expect(subject[4]['address']).to eq('mkgW6hNYBctmqDtTTsTJrsf2Gh2NPtoCU4')
        expect(subject[4]['oa_address']).to eq(address_to_oa_address('mkgW6hNYBctmqDtTTsTJrsf2Gh2NPtoCU4'))
        expect(subject[4]['script']).to eq('76a91438a6ebdf20cae2c9287ea014464042112ea3dbfd88ac')
        expect(subject[4]['amount']).to eq('0.00468200')
        expect(subject[4]['asset_id']).to be nil
        expect(subject[4]['asset_quantity']).to eq('0')
        expect(subject[4]['output_type']).to eq('transfer')
      end
    end

    describe 'send_assets' do
      context 'send multiple asset' do
        it do
          from = address_to_oa_address('mrxpeizRrF8ymNx5FrvcGGZVecZjtUFVP3')
          to = address_to_oa_address('n4MEsSUN8GktDFZzU3V55mP3jWGMN7e4wE')
          params = []
          params << OpenAssets::SendAssetParam.new('oGu4VXx2TU97d9LmPP8PMCkHckkcPqC5RY', 50, to)
          params << OpenAssets::SendAssetParam.new('oUygwarZqNGrjDvcZUpZdvEc7es6dcs1vs', 4, to)
          tx = create_api.send_assets(from, params, 10000, 'unsignd')
          expect(tx.inputs.length).to eq(6)
          expect(tx.outputs.length).to eq(6)
          # marker output
          marker_output_payload = OpenAssets::Protocol::MarkerOutput.parse_script(tx.outputs[0].pk_script)
          marker_output = OpenAssets::Protocol::MarkerOutput.deserialize_payload(marker_output_payload)
          expect(tx.outputs[0].value).to eq(0)
          expect(marker_output.asset_quantities).to eq([50, 22, 4, 2])
          # output for oGu4VXx2TU97d9LmPP8PMCkHckkcPqC5RY
          expect(tx.outputs[1].parsed_script.to_string).to eq('OP_DUP OP_HASH160 fa7491ee214ab15241a613fb5906f6df996bb08b OP_EQUALVERIFY OP_CHECKSIG')
          expect(tx.outputs[2].parsed_script.to_string).to eq('OP_DUP OP_HASH160 7d8dd16cc3413a64a9964c91cb0ee9358ab1dff6 OP_EQUALVERIFY OP_CHECKSIG')
          # output for oUygwarZqNGrjDvcZUpZdvEc7es6dcs1vs
          expect(tx.outputs[3].parsed_script.to_string).to eq('OP_DUP OP_HASH160 fa7491ee214ab15241a613fb5906f6df996bb08b OP_EQUALVERIFY OP_CHECKSIG')
          expect(tx.outputs[4].parsed_script.to_string).to eq('OP_DUP OP_HASH160 7d8dd16cc3413a64a9964c91cb0ee9358ab1dff6 OP_EQUALVERIFY OP_CHECKSIG')
          # output for otsuri
          expect(tx.outputs[5].parsed_script.to_string).to eq('OP_DUP OP_HASH160 7d8dd16cc3413a64a9964c91cb0ee9358ab1dff6 OP_EQUALVERIFY OP_CHECKSIG')
          expect(tx.outputs[5].value).to eq(90600)
        end
      end

      context 'send same asset using send_assets' do
        it do
          from = address_to_oa_address('mrxpeizRrF8ymNx5FrvcGGZVecZjtUFVP3')
          to1 = address_to_oa_address('n4MEsSUN8GktDFZzU3V55mP3jWGMN7e4wE')
          to2 = address_to_oa_address('msJ48aj11GcKuu3SK5nc5MPGrMxvE1oR5Y')
          params = []
          params << OpenAssets::SendAssetParam.new('oGu4VXx2TU97d9LmPP8PMCkHckkcPqC5RY', 30, to1)
          params << OpenAssets::SendAssetParam.new('oGu4VXx2TU97d9LmPP8PMCkHckkcPqC5RY', 20, to2)
          params << OpenAssets::SendAssetParam.new('oUygwarZqNGrjDvcZUpZdvEc7es6dcs1vs', 4, to1)
          tx = create_api.send_assets(from, params, 10000, 'unsignd')
          expect(tx.inputs.length).to eq(6)
          expect(tx.outputs.length).to eq(7)
          # marker output
          marker_output_payload = OpenAssets::Protocol::MarkerOutput.parse_script(tx.outputs[0].pk_script)
          marker_output = OpenAssets::Protocol::MarkerOutput.deserialize_payload(marker_output_payload)
          expect(tx.outputs[0].value).to eq(0)
          expect(marker_output.asset_quantities).to eq([30, 20, 22, 4, 2])
          # output for oGu4VXx2TU97d9LmPP8PMCkHckkcPqC5RY
          expect(tx.outputs[1].parsed_script.to_string).to eq('OP_DUP OP_HASH160 fa7491ee214ab15241a613fb5906f6df996bb08b OP_EQUALVERIFY OP_CHECKSIG')
          expect(tx.outputs[2].parsed_script.to_string).to eq('OP_DUP OP_HASH160 8130f96080e598cc4e210067eb54403074aa1a8d OP_EQUALVERIFY OP_CHECKSIG')
          expect(tx.outputs[3].parsed_script.to_string).to eq('OP_DUP OP_HASH160 7d8dd16cc3413a64a9964c91cb0ee9358ab1dff6 OP_EQUALVERIFY OP_CHECKSIG')
          # output for oUygwarZqNGrjDvcZUpZdvEc7es6dcs1vs
          expect(tx.outputs[4].parsed_script.to_string).to eq('OP_DUP OP_HASH160 fa7491ee214ab15241a613fb5906f6df996bb08b OP_EQUALVERIFY OP_CHECKSIG')
          expect(tx.outputs[5].parsed_script.to_string).to eq('OP_DUP OP_HASH160 7d8dd16cc3413a64a9964c91cb0ee9358ab1dff6 OP_EQUALVERIFY OP_CHECKSIG')
          # output for otsuri
          expect(tx.outputs[6].parsed_script.to_string).to eq('OP_DUP OP_HASH160 7d8dd16cc3413a64a9964c91cb0ee9358ab1dff6 OP_EQUALVERIFY OP_CHECKSIG')
          expect(tx.outputs[6].value).to eq(90000)
        end
      end
    end

    describe 'send bitcoin' do
      subject{
        from = 'mvYbB238p3rFYFjM56cHhNNHeQb5ypQJ3T'
        to1 = 'mjLSaCyJHCSeh4MsiNGnF1RLqD9ySqnAQ1'
        to2 = 'mnm6Lik5HqjrBXZtbRgTio4VSY5FyoUfrJ'
        params = []
        params << OpenAssets::SendBitcoinParam.new(20000, to1)
        params << OpenAssets::SendBitcoinParam.new(1000, to2)
        create_api.send_bitcoins(from, params, 10000, 'unsignd')
      }
      it 'send multiple bitcoins' do
        expect(subject.inputs.length).to eq(1)
        expect(subject.outputs.length).to eq(3)

        # output for otsuri mvYbB238p3rFYFjM56cHhNNHeQb5ypQJ3T
        expect(subject.outputs[0].parsed_script.get_address).to eq('mvYbB238p3rFYFjM56cHhNNHeQb5ypQJ3T')
        expect(subject.outputs[0].value).to eq(69000)
        # output for to_1 mjLSaCyJHCSeh4MsiNGnF1RLqD9ySqnAQ1
        expect(subject.outputs[1].parsed_script.get_address).to eq('mjLSaCyJHCSeh4MsiNGnF1RLqD9ySqnAQ1')
        expect(subject.outputs[1].value).to eq(20000)
        # output for to_2 mnm6Lik5HqjrBXZtbRgTio4VSY5FyoUfrJ
        expect(subject.outputs[2].parsed_script.get_address).to eq('mnm6Lik5HqjrBXZtbRgTio4VSY5FyoUfrJ')
        expect(subject.outputs[2].value).to eq(1000)
      end
    end

    describe 'burn asset' do
      oa_address = 'bX2vhttomKj2fdd7SJV2nv8U4zDjusE5Y4B'
      btc_address = oa_address_to_address(oa_address)
      asset_id = 'oGu4VXx2TU97d9LmPP8PMCkHckkcPqC5RY'

      context 'normal burn' do
        subject{
          create_api.burn_asset(oa_address, asset_id, 20000, 'unsignd')
        }
        it do
          expect(subject.inputs.length).to eq(4)
          expect(subject.inputs[0].prev_out_hash.reverse_hth).to eq('6887dd16b7ad2847bd4546211665199e05711c3acd1a67da879506adb5486910')
          expect(subject.inputs[0].prev_out_index).to eq(1)
          expect(subject.inputs[1].prev_out_hash.reverse_hth).to eq('6887dd16b7ad2847bd4546211665199e05711c3acd1a67da879506adb5486910')
          expect(subject.inputs[1].prev_out_index).to eq(2)
          expect(subject.inputs[2].prev_out_hash.reverse_hth).to eq('6887dd16b7ad2847bd4546211665199e05711c3acd1a67da879506adb5486910')
          expect(subject.inputs[2].prev_out_index).to eq(3)
          expect(subject.inputs[3].prev_out_hash.reverse_hth).to eq('308ea73b45bef1428acb41f996543d6ebd534dca8f5de965e7f00eae084aaa5c')
          expect(subject.inputs[3].prev_out_index).to eq(1)

          expect(subject.outputs.length).to eq(1)
          expect(subject.outputs[0].value).to eq(81800)
          script = Bitcoin::Script.new(Bitcoin::Script.to_hash160_script(Bitcoin.hash160_from_address(btc_address)))
          expect(subject.outputs[0].parsed_script.to_string).to eq(script.to_string)
        end
      end

      context 'not have enough fee' do
        it do
          expect{create_api.burn_asset(oa_address, asset_id, 101201, 'unsignd')}.to raise_error(OpenAssets::Transaction::InsufficientFundsError)
        end
      end

      context 'fee = utxo' do
        it do
          create_api.burn_asset(oa_address, asset_id, 101200, 'unsignd')
        end
      end

      context 'not have asset' do
        it do
          expect{create_api.burn_asset(oa_address, 'oZuo5eABTxR3fjQT9Dqi17jjqZsQpCXBE6', 10000, 'unsignd')}.to raise_error(OpenAssets::Transaction::TransactionBuildError)
        end
      end
    end

    describe 'cached tx' do

      context 'cache memory' do
        subject {
          testnet_mock = double('BitcoinCoreProviderTestnet Mock')
          api = OpenAssets::Api.new({:cache => ':memory:', :network => 'testnet'})
          allow(testnet_mock).to receive(:list_unspent).and_return(TESTNET_BTC_UNSPENT)
          setup_tx_load_mock(testnet_mock)
          allow(api).to receive(:provider).and_return(testnet_mock)
          api
        }
        it do
          txid = 'e1dcdb553d40ec35aac0a5b9bc2cce0112dd10c869a887b52b3b58071bb29f3c'
          out_index = 1
          expect(subject.provider).to receive(:get_transaction).with(txid, 0).once
          subject.get_output(txid, out_index)
          subject.get_output(txid, out_index)

          get_output_tx = '5004b6e4108ff2e39112e7b9fa596f225086373d33a1839af3e027a1cd259872'
          expect(subject.provider).to receive(:get_transaction).with(get_output_tx, 0).twice
          subject.get_outputs_from_txid(get_output_tx)
          subject.get_outputs_from_txid(get_output_tx)

          get_output_tx_cache = '9efbf61ef4805708ecf8e31d982ab6de20b2d131ed9be00d2856a5fe5a8b3df5'
          expect(subject.provider).to receive(:get_transaction).with(get_output_tx_cache, 0).once
          subject.get_outputs_from_txid(get_output_tx_cache, true)
          subject.get_outputs_from_txid(get_output_tx_cache, true)
        end
      end
    end
  end

  describe 'calculate fees' do
    subject {
      testnet_mock = double('BitcoinCoreProviderTestnet Mock')
      api = OpenAssets::Api.new({:cache => ':memory:', :network => 'testnet', :default_fees => :auto})
      allow(testnet_mock).to receive(:list_unspent).and_return(TESTNET_BTC_UNSPENT)
      setup_tx_load_mock(testnet_mock)
      allow(api).to receive(:provider).and_return(testnet_mock)
      api
    }
    it do
      from  = 'mvYbB238p3rFYFjM56cHhNNHeQb5ypQJ3T'
      to1   = 'mjLSaCyJHCSeh4MsiNGnF1RLqD9ySqnAQ1'
      to2   = 'mnm6Lik5HqjrBXZtbRgTio4VSY5FyoUfrJ'

      params = []
      params << OpenAssets::SendBitcoinParam.new(20000, to1)
      params << OpenAssets::SendBitcoinParam.new(1000, to2)

      tx = subject.send_bitcoins(from, params, :auto, 'unsignd')
      estimatefee_btc = subject.provider.estimatefee(1);
      estimatefee_satoshi = coin_to_satoshi(estimatefee_btc.to_s).to_i

      # actual value is 52061
      expected_otsuri = 79000 - (1 + tx.to_payload.bytesize/1_000) * estimatefee_satoshi

      # output for otsuri mvYbB238p3rFYFjM56cHhNNHeQb5ypQJ3T
      expect(tx.outputs[0].parsed_script.get_address).to eq('mvYbB238p3rFYFjM56cHhNNHeQb5ypQJ3T')
      expect(tx.outputs[0].value).to eq(expected_otsuri)
      # output for to_1 mjLSaCyJHCSeh4MsiNGnF1RLqD9ySqnAQ1
      expect(tx.outputs[1].parsed_script.get_address).to eq('mjLSaCyJHCSeh4MsiNGnF1RLqD9ySqnAQ1')
      expect(tx.outputs[1].value).to eq(20000)
      # output for to_2 mnm6Lik5HqjrBXZtbRgTio4VSY5FyoUfrJ
      expect(tx.outputs[2].parsed_script.get_address).to eq('mnm6Lik5HqjrBXZtbRgTio4VSY5FyoUfrJ')
      expect(tx.outputs[2].value).to eq(1000)
    end
  end

  def create_api
    testnet_mock = double('BitcoinCoreProviderTestnet Mock')
    api = OpenAssets::Api.new({:cache => ':memory:', :network => 'testnet'})
    allow(testnet_mock).to receive(:list_unspent).and_return(TESTNET_BTC_UNSPENT)
    setup_tx_load_mock(testnet_mock)
    allow(api).to receive(:provider).and_return(testnet_mock)
    api
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
    allow(btc_provider_mock).to receive(:get_transaction).with('6887dd16b7ad2847bd4546211665199e05711c3acd1a67da879506adb5486910', 0).and_return('0100000002e7a0899f2e66533f2d3501c50e149200d5a077f00761d2dbc873e6c1a902549e000000006a473044022055ee8e20e181898da602024b2985b1527621ed72017efd892fa32b9cdf8fab15022037ad071f95880ee3fea1845a0702ac6e8b01c3e9f3cbc82e51aeb7000cf12aac0121029362a6141d20521f77af9c5f2b6573527602baae2f9e8819039a874647e95346ffffffffe7a0899f2e66533f2d3501c50e149200d5a077f00761d2dbc873e6c1a902549e020000006a473044022041faeb6fad8a1eeda1d44b0770e229395249f1d97c340bc9d35e5c4542564322022037a642dcff8006e34875321a6770ccf0a331f20594704ccdb039640b2d6d2ead0121029362a6141d20521f77af9c5f2b6573527602baae2f9e8819039a874647e95346ffffffff0700000000000000000e6a0c4f410100051818181b85070058020000000000001976a9147d8dd16cc3413a64a9964c91cb0ee9358ab1dff688ac58020000000000001976a9147d8dd16cc3413a64a9964c91cb0ee9358ab1dff688ac58020000000000001976a9147d8dd16cc3413a64a9964c91cb0ee9358ab1dff688ac58020000000000001976a9147d8dd16cc3413a64a9964c91cb0ee9358ab1dff688ac58020000000000001976a914c70decc68bd86b6a8ae3a13b077af1a7304bdd5b88acc82c0100000000001976a914c70decc68bd86b6a8ae3a13b077af1a7304bdd5b88ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('9e5402a9c1e673c8dbd26107f077a0d50092140ec501352d3f53662e9f89a0e7', 0).and_return('010000000122c442b89c652e32ba7e2cff90715b834b71834526bd509295baea5965b71e2d010000006a47304402202986a33a7c6077eb8039bbe39b304917f3dc655cc5b30a17d729f864fb1a19c502206e8e0c411018d41dfe0380b673a010e75fea6411ca9187f983084da5da6fefc50121029362a6141d20521f77af9c5f2b6573527602baae2f9e8819039a874647e95346ffffffff0358020000000000001976a914c70decc68bd86b6a8ae3a13b077af1a7304bdd5b88ac0000000000000000216a1f4f41010001e80717753d68747470733a2f2f676f6f2e676c2f755667737434385d0100000000001976a914c70decc68bd86b6a8ae3a13b077af1a7304bdd5b88ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('2d1eb76559eaba959250bd264583714b835b7190ff2c7eba322e659cb842c422', 0).and_return('01000000011c963366a33ab3df14243e22ed1a893cca3f5d315b4b7b5755503c96a4f1dbc4000000006a4730440220305cb233b6996d57d7eca72d1c571dbc867aa7f1f7444ad980cf028e7994bc74022040e31c3d6c2224949ed2e43bbc10c04ede6ac5cf7a33d3cfca6862096437742b012103e96fd7e921b64954bbff1eec73b0331c8c9d27aa70b0520eb36b50019a978f1cffffffff0206f37847000000001976a914d3c96dc04a62f488a3f1b588f74af136469c6fca88aca0860100000000001976a914c70decc68bd86b6a8ae3a13b077af1a7304bdd5b88ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('9ece6cdda95805e47667f0b389ee3c0c29efd5929bc372e68a34ac1ecbb92d6f', 0).and_return('0100000002bab7d2b0bfdd11bb8e7757bc575398bbaa8f30110f56590e1bf2dfff0c210c37000000006b483045022100ef7e82e77372407da5586acd77cf61a9d7682782b7ead0450ae220d07913555c0220101cb1a026a4c81204a01ec0c02e237f0d0c22f31fd87030e85640f1a53a2d5c0121033917dfab0a99833380034fa77159a812feb8333382e53075b88dcbebfde7cc49ffffffffbab7d2b0bfdd11bb8e7757bc575398bbaa8f30110f56590e1bf2dfff0c210c37020000006b483045022100ae225c601583b1e8cf6190ac6f7ae32df94aeb347d6bb7d17ee98532b94e9379022010718ac1a2c68a21e1f80bdd7f7fcd42866d50006ecdcda341cc8c40419403770121033917dfab0a99833380034fa77159a812feb8333382e53075b88dcbebfde7cc49ffffffff0600000000000000000d6a0b4f41010004030304de070058020000000000001976a9147d8dd16cc3413a64a9964c91cb0ee9358ab1dff688ac58020000000000001976a9147d8dd16cc3413a64a9964c91cb0ee9358ab1dff688ac58020000000000001976a9147d8dd16cc3413a64a9964c91cb0ee9358ab1dff688ac58020000000000001976a914a938dad89bbd964cbaf5d9059e0bda1d900ce08388ac202f0100000000001976a914a938dad89bbd964cbaf5d9059e0bda1d900ce08388ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('370c210cffdff21b0e59560f11308faabb985357bc57778ebb11ddbfb0d2b7ba', 0).and_return('01000000011c963366a33ab3df14243e22ed1a893cca3f5d315b4b7b5755503c96a4f1dbc4010000006b48304502210089b69fa58bf02bffa9399aa4328e3f9816d4041f4b2a0b8e00c0d1ad37c5cfbe022029423551060bedb943f5ff1ff1c4e91cfc7fdbc21d5035c580cfc4ef4b2156810121033917dfab0a99833380034fa77159a812feb8333382e53075b88dcbebfde7cc49ffffffff0358020000000000001976a914a938dad89bbd964cbaf5d9059e0bda1d900ce08388ac0000000000000000216a1f4f41010001e80717753d68747470733a2f2f676f6f2e676c2f755667737434385d0100000000001976a914a938dad89bbd964cbaf5d9059e0bda1d900ce08388ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('c4dbf1a4963c5055577b4b5b315d3fca3c891aed223e2414dfb33aa36633961c', 0).and_return('010000000175552d5eddd4494aa6b05dcec201eec8280d0e2840b3843aaf884df15ce328f4010000006b483045022100e0a219f87cea50c95a45fca4204c3fe25d0e44baa54c498afbc657ed6c20f4bf0220329892eb524487a1b8724c531b27602794cdadca365681a9f62a054fb1c4713f012103e96fd7e921b64954bbff1eec73b0331c8c9d27aa70b0520eb36b50019a978f1cffffffff02b6a07a47000000001976a914d3c96dc04a62f488a3f1b588f74af136469c6fca88aca0860100000000001976a914a938dad89bbd964cbaf5d9059e0bda1d900ce08388ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('308ea73b45bef1428acb41f996543d6ebd534dca8f5de965e7f00eae084aaa5c', 0).and_return('010000000122c442b89c652e32ba7e2cff90715b834b71834526bd509295baea5965b71e2d000000006b48304502210095b72684aa4a8355f4057d476ac222a683220fa0087ca99d2efcea0149ff1287022014c77b8f9e0d0f457792f562a09517d752cde5c7d7b941c5ad33a95fe471b66b012103e96fd7e921b64954bbff1eec73b0331c8c9d27aa70b0520eb36b50019a978f1cffffffff0256457747000000001976a914d3c96dc04a62f488a3f1b588f74af136469c6fca88aca0860100000000001976a9147d8dd16cc3413a64a9964c91cb0ee9358ab1dff688ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('5004b6e4108ff2e39112e7b9fa596f225086373d33a1839af3e027a1cd259872', 0).and_return('0100000001181fbb20375c941384069fdefd739c8e14fa40490a335607da6ea912f4383cab010000006a47304402205ddd66e0e59e3d377298a5ce2ece08804a49e0ca55215c0500e00871f75390ad0220452f91c7beea5b20b0b6c23f0dc3294ed36dbffec15dd8294cdf31d683ea5f850121024126e617f993a6fd24bb344a6c13f16f20bea4c74e451232fea494a8b53516cdffffffff0358020000000000001976a914147b897573a9586f64320d29c7780f383d00f06d88ac0000000000000000216a1f4f41010001890617753d68747470733a2f2f676f6f2e676c2f36704e503237e8990000000000001976a914147b897573a9586f64320d29c7780f383d00f06d88ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('ab3c38f412a96eda0756330a4940fa148e9c73fdde9f068413945c3720bb1f18', 0).and_return('0100000001b43aca2d4f5b4ca395e54057a420180136adb1a9d7dfe0f22b2d68ec41bce90e000000006b48304502210099171aa53917c566c55c27543012f430b2dcac118101e83168a5da97703c3229022024958d98c54ad0390e4afcfbae233c3c2d68936c5626c27b51fe452caaca350c012103e96fd7e921b64954bbff1eec73b0331c8c9d27aa70b0520eb36b50019a978f1cffffffff0296ff7247000000001976a914d3c96dc04a62f488a3f1b588f74af136469c6fca88ac50c30000000000001976a914147b897573a9586f64320d29c7780f383d00f06d88ac00000000')
    # addr = mvYbB238p3rFYFjM56cHhNNHeQb5ypQJ3T (with some bitcoins)
    allow(btc_provider_mock).to receive(:get_transaction).with('4cf37617ed99b246724067991346c31734f4147288d963a485c81f25b3572a89', 0).and_return('0100000001742471c85c1ea03c79da272fa3b62b9537c260917be1d5dbb783ea8c0652ca3b000000006a473044022045f8af3f915d4c8b9ca6aa281247a1484ec19260ecdf4f57c0d52160e7b240d20220509857ae2348860ab9d4db4da12536a19d1dffbf4f4688d334954c5d04533b52012103da05e349a9c676e66efe78fa6603d8667dcd94e213e827a0ca61a143a9f3677cffffffff0358020000000000001976a914a4d91666eb7cc21a3fff959861a629354e4275b288ac00000000000000001d6a1b4f41010001b96013753d687474703a2f2f676f6f676c652e636f6d78caae06000000001976a914a4d91666eb7cc21a3fff959861a629354e4275b288ac00000000')
    # addr = mjLSaCyJHCSeh4MsiNGnF1RLqD9ySqnAQ1
    allow(btc_provider_mock).to receive(:get_transaction).with('7dd8296f38db7148d81fa88114becd96fd5064113bea0bcf1c24809ea863ee5a', 0).and_return('01000000032faa228eeb2aa59b652f9e90020224482a93e56650505323de8f8f8f1de83d8b020000006a473044022063a8bc218fc1309428f65f222272215a739ba6ec3ef4b4602b22da9eb2ce6ed202207f8e0e60d418a8fa66d4608ff13829df6d40b7cbd52223390678aebeb37063b601210372107bf36f6c980bf5070e7004c743396bde827c5d735a9fcbcb35f215f23173ffffffffc1531abc3a82f6ac4f9b0c9dbd821b8626f335d4fa89c16100b3748a28a1d429020000006a4730440220674c828a08ab9545d3e82fa3720b3d66ceaed4e5fd241a27dd1f54fd126b325b022077debe1ebc3395a9283587f0b074dc1f8ce1b0483775180ecfccf990ae8d0f5f01210372107bf36f6c980bf5070e7004c743396bde827c5d735a9fcbcb35f215f23173ffffffff6bfed6ec52a26110a2bfdf65ffd18196a3913e7bb03629e6b9be1ff02ad7d07f020000006a47304402202a227da68fa66ed75886baee16eb565740473f699c6a5bd900aea610d27f63c202207d61b50e80b5f1a3fce481e59c733aaf8cc0624f8a5380d44a46d1143f704bc801210372107bf36f6c980bf5070e7004c743396bde827c5d735a9fcbcb35f215f23173ffffffff0196e20500000000001976a91429e38883cd397cf8f53d1676abd6dcad25cc134888ac00000000')
    # addr = mnm6Lik5HqjrBXZtbRgTio4VSY5FyoUfrJ
    allow(btc_provider_mock).to receive(:get_transaction).with('f889c52a3367f636b9b680e84b22ea42a22b1ca41f9f59cb541c44ed3798a36c', 0).and_return('0100000004147baa40b3426ee6d55e6697fc3f2500c891f0619284713875b05d87143e8fe7000000006b483045022100bdf97b349f300b46aa0b624f7f90fa8085623805585b53739e7ab70cbe6d0a5e02203d6a116128683009b25efc09893f14b2604e8777e04cefece62766d45888c9c401210323df5c63ab7a9186ecfdbc07ee9acc5cb4129c65622d8c436dc2ed2d625cd143ffffffff1f332638e05adfcd7628d018733a6bbf70bb7ee2b6f7c15f5437b918be2270f7000000006b4830450221009a6ffa886f1f53d53123e594324f21f0af149da95db63c942e2844c3eb836a6602203ddcda271c0fa96a2457cc34736f2254cd1d996e3926ec378b6a2f88a8ccf2a201210323df5c63ab7a9186ecfdbc07ee9acc5cb4129c65622d8c436dc2ed2d625cd143ffffffffac93eb66ea41c7e1f186e2a7505adbe9c45ca924876118a3957a93ad43c32623010000006b4830450221009313374d4391ff442c44bfc3e4ff62874069d3eb5c992688607ab6f59c852c5802203a4cb9027262bbc11c576792c1e49248ae859a069a5a16d6e403f837c821c5eb01210323df5c63ab7a9186ecfdbc07ee9acc5cb4129c65622d8c436dc2ed2d625cd143ffffffff3672675c2dd1d92d0848d954d7b6b3da9d48ce61115db1bed1369d2e024e7cea010000006b483045022100adb92a6c865ba59627af9dfe7dfedd7d2620035c023b9fc8dbda843adf99881702204f6c59d78d8615c5cff7e388f43b4fbd763797fc2dc1f38fd6c70bd3634ada0801210323df5c63ab7a9186ecfdbc07ee9acc5cb4129c65622d8c436dc2ed2d625cd143ffffffff0600000000000000000e6a0c4f41010004c20332c203320058020000000000001976a91453ad0e81bd931dac736ad913915d11c3be0c0b2388ac58020000000000001976a91453ad0e81bd931dac736ad913915d11c3be0c0b2388ac58020000000000001976a9143894aaab84a2c8a2f29c085573bb8aae2a0f94e288ac58020000000000001976a91460c707f73615f6263761bf20522f0ed54e1b2e0488acb8770700000000001976a9144f756b9ed6608e5d66ee92b761cf99641940cee688ac00000000')
    allow(btc_provider_mock).to receive(:estimatefee).and_return(0.00026939)
  end

  TESTNET_BTC_UNSPENT = [
      {"txid" => "e1dcdb553d40ec35aac0a5b9bc2cce0112dd10c869a887b52b3b58071bb29f3c",
       "vout" => 0,
       "address" => "msJ48aj11GcKuu3SK5nc5MPGrMxvE1oR5Y",
       "account" => "",
       "scriptPubKey" => "76a9148130f96080e598cc4e210067eb54403074aa1a8d88ac",
       "amount" => 0.00000600,
       "confirmations" => 1,
       "spendable" => true,
       "solvable" => true
      },
      {"txid" => "6887dd16b7ad2847bd4546211665199e05711c3acd1a67da879506adb5486910",
       "vout" => 1,
       "address" => "7d8dd16cc3413a64a9964c91cb0ee9358ab1dff6",
       "account" => "",
       "scriptPubKey" => "",
       "amount" => 0.00000600,
       "confirmations" => 1,
       "spendable" => true,
       "solvable" => true
      },
      {"txid" => "6887dd16b7ad2847bd4546211665199e05711c3acd1a67da879506adb5486910",
        "vout" => 2,
        "address" => "mrxpeizRrF8ymNx5FrvcGGZVecZjtUFVP3",
        "account" => "",
        "scriptPubKey" => "7d8dd16cc3413a64a9964c91cb0ee9358ab1dff6",
        "amount" => 0.00000600,
        "confirmations" => 1,
        "spendable" => true,
        "solvable" => true
      },
      {"txid" => "6887dd16b7ad2847bd4546211665199e05711c3acd1a67da879506adb5486910",
       "vout" => 3,
       "address" => "mrxpeizRrF8ymNx5FrvcGGZVecZjtUFVP3",
       "account" => "",
       "scriptPubKey" => "7d8dd16cc3413a64a9964c91cb0ee9358ab1dff6",
       "amount" => 0.00000600,
       "confirmations" => 1,
       "spendable" => true,
       "solvable" => true
      },
      {"txid" => "9ece6cdda95805e47667f0b389ee3c0c29efd5929bc372e68a34ac1ecbb92d6f",
        "vout" => 1,
       "address" => "mrxpeizRrF8ymNx5FrvcGGZVecZjtUFVP3",
       "account" => "",
       "scriptPubKey" => "7d8dd16cc3413a64a9964c91cb0ee9358ab1dff6",
       "amount" => 0.00000600,
       "confirmations" => 1,
       "spendable" => true,
       "solvable" => true
      },
      {"txid" => "9ece6cdda95805e47667f0b389ee3c0c29efd5929bc372e68a34ac1ecbb92d6f",
        "vout" => 2,
       "address" => "mrxpeizRrF8ymNx5FrvcGGZVecZjtUFVP3",
       "account" => "",
       "scriptPubKey" => "7d8dd16cc3413a64a9964c91cb0ee9358ab1dff6",
       "amount" => 0.00000600,
       "confirmations" => 1,
       "spendable" => true,
       "solvable" => true
      },
      {"txid" => "308ea73b45bef1428acb41f996543d6ebd534dca8f5de965e7f00eae084aaa5c",
       "vout" => 1,
       "address" => "mzpnB3S31yZRDJFLmTd1ZsWJTtzymL7HsA",
       "account" => "",
       "scriptPubKey" => "d3c96dc04a62f488a3f1b588f74af136469c6fca",
       "amount" => 0.00000600,
       "confirmations" => 1,
       "spendable" => true,
       "solvable" => true
      },
      {
        "txid" => "5004b6e4108ff2e39112e7b9fa596f225086373d33a1839af3e027a1cd259872",
        "vout" => 0,
        "confirmations" => 8957,
        "address" => "mhPFoPUSefNW7BMV8bhL3Pa4qkP4vtJaba",
        "script" => "76a914147b897573a9586f64320d29c7780f383d00f06d88ac",
        "amount" => 0.00000600,
        "account" => "proof-of-authenticity",
        "spendable" => true,
        "solvable" => true
      }
  ]

end