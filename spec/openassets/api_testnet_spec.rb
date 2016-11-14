require 'spec_helper'

describe 'OpenAssets::Api use testnet', :network => :testnet do

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
      context 'standard tx' do
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

      context 'issuance tx with p2sh' do
        subject{
          create_api.get_outputs_from_txid('a98b000f28c9e8251925a1225832edf1c2992e103445b6b2cec3f5c0a81469e5')[0]
        }
        it do
          expect(subject['output_type']).to eq('issuance')
          expect(subject['asset_id']).to eq('oMb2yzA542yQgwn8XtmGefTzBv5NJ2nDjh')
          expect(subject['asset_definition_url']).to eq('https://goo.gl/bmVEuw')
        end
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
          load_tx_mock(testnet_mock)
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
      load_tx_mock(testnet_mock)
      allow(api).to receive(:provider).and_return(testnet_mock)
      allow(testnet_mock).to receive(:estimatefee).and_return(0.00026939)
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
    load_tx_mock(testnet_mock)
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