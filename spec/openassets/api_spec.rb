require 'spec_helper'

describe OpenAssets::Api do

  include OpenAssets::Util

  it 'load configuration' do
    api = OpenAssets::Api.new
    expect(api.is_testnet?).to be false
    expect(api.config[:rpc][:host]).to eq('localhost')
    expect(api.config[:rpc][:port]).to eq(8332)
    api = OpenAssets::Api.new(JSON.parse(File.read("#{File.dirname(__FILE__)}/../test-config.json"), {:symbolize_names => true}))
    expect(api.is_testnet?).to be true
    expect{OpenAssets::Api.new({:provider => 'hoge'})}.to raise_error(OpenAssets::Error)
  end

  context 'use provider' do
    subject {
      btc_provider_mock = double('BitcoinCoreProvider Mock')
      api = OpenAssets::Api.new
      allow(btc_provider_mock).to receive(:list_unspent).and_return(BTC_UNSPENT)
      setup_tx_load_mock(btc_provider_mock)
      allow(api).to receive(:provider).and_return(btc_provider_mock)
      api
    }

    it 'list_unspent' do
      list = subject.list_unspent
      list.each_with_index { |result, index |
        expect(result['txid']).to eq(OA_UNSPENT[index]['txid'])
        expect(result['asset_id']).to eq(OA_UNSPENT[index]['asset_id'])
        expect(result['script']).to eq(OA_UNSPENT[index]['script'])
        expect(result['amount']).to eq(OA_UNSPENT[index]['amount'])
        expect(result['confirmations']).to eq(OA_UNSPENT[index]['confirmations'])
        expect(result['oa_address']).to eq(OA_UNSPENT[index]['oa_address'])
        expect(result['address']).to eq(OA_UNSPENT[index]['address'])
        expect(result['asset_quantity']).to eq(OA_UNSPENT[index]['asset_quantity'])
        expect(result['account']).to eq(get_account(result['address']))
      }

      list = subject.list_unspent(['akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6'])
      expect(list.length).to eq(3)
      list.each{|r|expect(r['oa_address']).to eq('akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6')}

      expect(subject.list_unspent(['akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t8']).length).to eq(0)
    end

    it 'get_balance' do
      balances = subject.get_balance
      expect(balances.length).to eq(OA_BALANCE.length)
      balances.each_with_index { |balance, index|
        expect(balance['oa_address']).to eq(OA_BALANCE[index][:oa_address])
        expect(balance['address']).to eq(OA_BALANCE[index][:address])
        expect(balance['account']).to eq(get_account(balance['address']))
        expect(balance['value']).to eq(OA_BALANCE[index][:value])
        assets = balance['assets']
        expect(assets.length).to eq(OA_BALANCE[index][:assets].length)
        assets.each_with_index { |a, i|
          expect(a['asset_id']).to eq((OA_BALANCE[index][:assets][i][:asset_id]))
          expect(a['quantity']).to eq((OA_BALANCE[index][:assets][i][:quantity]))
        }
      }
      balances = subject.get_balance('akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6')
      expect(balances.length).to eq(1)
      balance = balances[0]
      expect(balance['oa_address']).to eq('akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6')
      expect(balance['assets'][0]['quantity']).to eq('24')

      expect(subject.get_balance('akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t8').length).to eq(0)
    end

    it 'issue_asset' do
      address = 'akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH'
      tx = subject.issue_asset(
        address, 125, 'u=https://goo.gl/bmVEuw', address, nil, 'unsigned', 2)
      expect(tx.ver).to eq(1)
      expect(tx.lock_time).to eq(0)
      expect(tx.inputs.length).to eq(1)
      expect(tx.inputs[0].prev_out.reverse_hth).to eq('21b093ec41244898a50e1f97cb80fd98d7714c7235e0a4a30d7d0c6fb6a6ce8a')
      expect(tx.inputs[0].prev_out_index).to eq(1)
      expect(tx.outputs.length).to eq(4)
      # issue output
      expect(tx.outputs[0].value).to eq(600)
      expect(tx.outputs[0].parsed_script.to_string).to eq('OP_DUP OP_HASH160 24b3d405bc60bd9628691fe28bb00f6800e14806 OP_EQUALVERIFY OP_CHECKSIG')
      expect(tx.outputs[1].value).to eq(600)
      expect(tx.outputs[1].parsed_script.to_string).to eq('OP_DUP OP_HASH160 24b3d405bc60bd9628691fe28bb00f6800e14806 OP_EQUALVERIFY OP_CHECKSIG')
      # marker output
      marker_output_payload = OpenAssets::Protocol::MarkerOutput.parse_script(tx.outputs[2].pk_script)
      marker_output = OpenAssets::Protocol::MarkerOutput.deserialize_payload(marker_output_payload)
      expect(tx.outputs[2].value).to eq(0)
      expect(marker_output.asset_quantities).to eq([62, 63])
      expect(marker_output.metadata).to eq('u=https://goo.gl/bmVEuw')
      # bitcoin change
      expect(tx.outputs[3].value).to eq(89400) # prev_out value: 100000 - issue dust: 600 - default_fees: 10000 = 89400
      expect(tx.outputs[3].parsed_script.to_string).to eq('OP_DUP OP_HASH160 24b3d405bc60bd9628691fe28bb00f6800e14806 OP_EQUALVERIFY OP_CHECKSIG')
    end

    it 'issue_asset metadata nil' do
      address = 'akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH'
      tx = subject.issue_asset(address, 125, nil, address, nil, 'unsigned')
      expect(tx.inputs.length).to eq(1)
      expect(tx.outputs.length).to eq(3)
      marker_output_payload = OpenAssets::Protocol::MarkerOutput.parse_script(tx.outputs[1].pk_script)
      marker_output = OpenAssets::Protocol::MarkerOutput.deserialize_payload(marker_output_payload)
      expect(tx.outputs[1].value).to eq(0)
      expect(marker_output.asset_quantities).to eq([125])
      expect(marker_output.metadata).to eq('')
    end

  end

  context 'use provider send asset' do
    subject {
      btc_provider_mock = double('BitcoinCoreProvider Mock')
      api = OpenAssets::Api.new
      allow(btc_provider_mock).to receive(:list_unspent).and_return(filter_btc_unspent('1HhJs3JgbiyxC8ktfi6nU4wTqVmrMtCVkG'))
      setup_tx_load_mock(btc_provider_mock)
      allow(api).to receive(:provider).and_return(btc_provider_mock)
      api
    }
    it 'send_asset' do
      asset_id = 'AWo3R89p5REmoSyMWB8AeUmud8456bRxZL'
      from = 'akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6'
      to = 'akP4AgdxY5zsfSxM6Jach3YQGZE7vM1o8si'
      tx = subject.send_asset(from, asset_id, 10, to, 10000, 'unsigned')
      # actual test txid = f9922c146b386fc7017a12d0ed8ee9fdd4b93442600eff771d6211772d349a73
      expect(tx.ver).to eq(1)
      expect(tx.lock_time).to eq(0)
      expect(tx.inputs.length).to eq(3)
      expect(tx.inputs[0].prev_out_index).to eq(2)
      expect(tx.inputs[0].prev_out.reverse_hth).to eq('97f5fdfe133005c033ea3185202c53bb59d0760e9f9dd2cc2f8c50bbce8ec8bb')
      expect(tx.inputs[1].prev_out_index).to eq(2)
      expect(tx.inputs[1].prev_out.reverse_hth).to eq('9da5541e6653b03437264ab249170dccee24cdfe6351826df2f4b63079df2d4d')
      # ↑の２つのUTXOはアセット転送のアウトプットで、Bitcoinが不足してるので↓のトランザクションも追加
      expect(tx.inputs[2].prev_out_index).to eq(2)
      expect(tx.inputs[2].prev_out.reverse_hth).to eq('92ecb6c38bfefc3b6ff8b48a2dd14ece823d37c02adbeeeeede5a801e4926ece')

      expect(tx.outputs.length).to eq(4)
      # marker output
      marker_output_payload = OpenAssets::Protocol::MarkerOutput.parse_script(tx.outputs[0].pk_script)
      marker_output = OpenAssets::Protocol::MarkerOutput.deserialize_payload(marker_output_payload)
      expect(tx.outputs[0].value).to eq(0)
      expect(marker_output.asset_quantities).to eq([10, 14])
      # asset transfer
      expect(tx.outputs[1].value).to eq(600)
      expect(tx.outputs[1].parsed_script.to_string).to eq('OP_DUP OP_HASH160 84a14fd7c4c522d59158f91f78c250278f66a899 OP_EQUALVERIFY OP_CHECKSIG')
      expect(tx.outputs[2].value).to eq(600)
      expect(tx.outputs[2].parsed_script.to_string).to eq('OP_DUP OP_HASH160 b7218fe503cd18555255e5b13d4f07f3fd00d0c9 OP_EQUALVERIFY OP_CHECKSIG')
      # bitcoin rest
      expect(tx.outputs[3].value).to eq(16400)
      expect(tx.outputs[3].parsed_script.to_string).to eq('OP_DUP OP_HASH160 b7218fe503cd18555255e5b13d4f07f3fd00d0c9 OP_EQUALVERIFY OP_CHECKSIG')

      # split output_qty
      tx = subject.send_asset(from, asset_id, 10, to, 10000, 'unsigned', 3)
      expect(tx.outputs.length).to eq(6)
      marker_output_payload = OpenAssets::Protocol::MarkerOutput.parse_script(tx.outputs[0].pk_script)
      marker_output = OpenAssets::Protocol::MarkerOutput.deserialize_payload(marker_output_payload)
      expect(tx.outputs[0].value).to eq(0)
      expect(marker_output.asset_quantities).to eq([3, 3, 4, 14])
      expect(tx.outputs[1].value).to eq(600)
      expect(tx.outputs[1].parsed_script.to_string).to eq('OP_DUP OP_HASH160 84a14fd7c4c522d59158f91f78c250278f66a899 OP_EQUALVERIFY OP_CHECKSIG')
      expect(tx.outputs[2].value).to eq(600)
      expect(tx.outputs[2].parsed_script.to_string).to eq('OP_DUP OP_HASH160 84a14fd7c4c522d59158f91f78c250278f66a899 OP_EQUALVERIFY OP_CHECKSIG')
      expect(tx.outputs[3].value).to eq(600)
      expect(tx.outputs[3].parsed_script.to_string).to eq('OP_DUP OP_HASH160 84a14fd7c4c522d59158f91f78c250278f66a899 OP_EQUALVERIFY OP_CHECKSIG')
      expect(tx.outputs[4].value).to eq(600)
      expect(tx.outputs[4].parsed_script.to_string).to eq('OP_DUP OP_HASH160 b7218fe503cd18555255e5b13d4f07f3fd00d0c9 OP_EQUALVERIFY OP_CHECKSIG')
      # bitcoin rest
      expect(tx.outputs[5].value).to eq(15200)
      expect(tx.outputs[5].parsed_script.to_string).to eq('OP_DUP OP_HASH160 b7218fe503cd18555255e5b13d4f07f3fd00d0c9 OP_EQUALVERIFY OP_CHECKSIG')

    end

    it 'send_bitcoin' do
      address = '1HhJs3JgbiyxC8ktfi6nU4wTqVmrMtCVkG'
      # 26400 satoshiのUTXOを保持してるが、残り600✕2のOAのUTXOを保持してる
      expect{subject.send_bitcoin(address, 16401, address, nil, 'unsigned')}.to raise_error(OpenAssets::Transaction::InsufficientFundsError)
      tx = subject.send_bitcoin(address, 16400, address, nil, 'unsigned')
      expect(tx.inputs.length).to eq(1)
      expect(tx.outputs.length).to eq(1)
      expect(tx.outputs[0].value).to eq(16400)

      tx = subject.send_bitcoin(address, 16400, address, nil, 'unsigned', 3)
      expect(tx.inputs.length).to eq(1)
      expect(tx.outputs.length).to eq(3)
      expect(tx.outputs[0].value).to eq(5466)
      expect(tx.outputs[0].parsed_script.to_string).to eq('OP_DUP OP_HASH160 b7218fe503cd18555255e5b13d4f07f3fd00d0c9 OP_EQUALVERIFY OP_CHECKSIG')
      expect(tx.outputs[1].value).to eq(5466)
      expect(tx.outputs[1].parsed_script.to_string).to eq('OP_DUP OP_HASH160 b7218fe503cd18555255e5b13d4f07f3fd00d0c9 OP_EQUALVERIFY OP_CHECKSIG')
      expect(tx.outputs[2].value).to eq(5468)
      expect(tx.outputs[2].parsed_script.to_string).to eq('OP_DUP OP_HASH160 b7218fe503cd18555255e5b13d4f07f3fd00d0c9 OP_EQUALVERIFY OP_CHECKSIG')

      tx = subject.send_bitcoin(address, 13000, address, nil, 'unsigned', 3)
      expect(tx.inputs.length).to eq(1)
      expect(tx.outputs.length).to eq(4)
      expect(tx.outputs[0].value).to eq(3400)
      expect(tx.outputs[0].parsed_script.to_string).to eq('OP_DUP OP_HASH160 b7218fe503cd18555255e5b13d4f07f3fd00d0c9 OP_EQUALVERIFY OP_CHECKSIG')
      expect(tx.outputs[1].value).to eq(4333)
      expect(tx.outputs[1].parsed_script.to_string).to eq('OP_DUP OP_HASH160 b7218fe503cd18555255e5b13d4f07f3fd00d0c9 OP_EQUALVERIFY OP_CHECKSIG')
      expect(tx.outputs[2].value).to eq(4333)
      expect(tx.outputs[2].parsed_script.to_string).to eq('OP_DUP OP_HASH160 b7218fe503cd18555255e5b13d4f07f3fd00d0c9 OP_EQUALVERIFY OP_CHECKSIG')
      expect(tx.outputs[3].value).to eq(4334)
      expect(tx.outputs[3].parsed_script.to_string).to eq('OP_DUP OP_HASH160 b7218fe503cd18555255e5b13d4f07f3fd00d0c9 OP_EQUALVERIFY OP_CHECKSIG')
    end

  end

  context 'divisibility spec' do
    subject {
      btc_provider_mock = double('BitcoinCoreProvider Mock')
      api = OpenAssets::Api.new
      allow(btc_provider_mock).to receive(:list_unspent).and_return(DIVISIBILITY_UNSPENT)
      setup_tx_load_mock(btc_provider_mock)
      allow(api).to receive(:provider).and_return(btc_provider_mock)
      api
    }

    it 'list unspent' do
      unspent = subject.list_unspent(['akNLRWpJCmwzJjaHvoBGeWAca7K6HLgwyvv'])
      expect(unspent[0]['asset_id']).to eq('AJk2Gx5V67S2wNuwTK5hef3TpHunfbjcmX')
      expect(unspent[0]['asset_quantity']).to eq('1433')
      expect(unspent[0]['asset_amount']).to eq('143.3')
      expect(unspent[0]['asset_definition_url']).to eq('http://goo.gl/fS4mEj')

      unspent = subject.list_unspent(['akPKayJJg4DGAnx9tqBeyAzoG3imbdrJmNv'])
      expect(unspent[0]['asset_id']).to eq('AdMs8umPHqWWoefCQQiboe3qfXBRkMQKY6')
      expect(unspent[0]['asset_quantity']).to eq('2000')
      expect(unspent[0]['asset_amount']).to eq('2000')
      expect(unspent[0]['asset_definition_url']).to eq('The asset definition is invalid. http://goo.gl/fS4mEj')
    end

    it 'get_balance' do
      balance = subject.get_balance
      puts JSON.pretty_generate(balance)
      expect(balance[0]['oa_address']).to eq('akNLRWpJCmwzJjaHvoBGeWAca7K6HLgwyvv')
      expect(balance[0]['assets'][0]['asset_id']).to eq('AJk2Gx5V67S2wNuwTK5hef3TpHunfbjcmX')
      expect(balance[0]['assets'][0]['quantity']).to eq('1433')
      expect(balance[0]['assets'][0]['amount']).to eq('143.3')
      expect(balance[0]['assets'][0]['asset_definition_url']).to eq('http://goo.gl/fS4mEj')
    end
  end

  def filter_btc_unspent(btc_address = nil)
    return BTC_UNSPENT if btc_address.nil?
    BTC_UNSPENT.select{|u|u['address'] == btc_address}
  end

  def get_account(btc_address)
    BTC_UNSPENT.select{|u|u['address'] == btc_address}.first['account']
  end

  def setup_tx_load_mock(btc_provider_mock)
    allow(btc_provider_mock).to receive(:get_transaction).with('21b093ec41244898a50e1f97cb80fd98d7714c7235e0a4a30d7d0c6fb6a6ce8a', 0).and_return('010000000108fcc35a4b46b36be2b07b5dc06bb635956597d5ea79b028a0a2f70ae6cf6fd6010000006a4730440220325a1bc5fe119e87f0b15e7f542107e1e839f3f8b241a91eebb33ee74612d65502207df2580d7b7105f4353e730c2a6df2e89c9cb77ad9fc9f6e066f444dca82e298012103996ffca62815a75befba6b85ef0c5e03bc3548db16c2b0642225417c94a80cbfffffffff02e33e0500000000001976a914fcefa84d15d0bf818b020f0cdaf99f4029c15ce788aca0860100000000001976a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('3fba8bfb157ae29c293d5bd65c178fec169a87f880e2e62537fcce26612a6aa3', 0).and_return('01000000022a06e3f9bcf491143d23b1446585778fd316d88908b35f5faf86981b803e8764020000006a47304402206f03f9c51d68af384411a17de35df3cfe20ba6fa0546a17a7651f1e2ea72ae43022045358a7d7c7637d964b367cea526bd63f3817a8729f221f1856b1d992ca71b33012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffff2a06e3f9bcf491143d23b1446585778fd316d88908b35f5faf86981b803e8764030000006b483045022100bb6f5d76f7d61c068dcd8fc077a3afe85e890f41442368212a36a6acfeed25fb0220337a5fa68e676ff5231c7c33ba31119f2eb77935795f078ddb5489f37725b9e2012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffff0400000000000000000a6a084f4101000201020058020000000000001976a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac58020000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac78310100000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('64873e801b9886af5f5fb30889d816d38f77856544b1233d1491f4bcf9e3062a', 0).and_return('01000000021a8dbbbc32c6803851d34478dccd71b80112be9f784f688c83f857098ca129a3020000006a47304402204a8314a129b7374087965ee1878a427c798a6882982c89d59909ecd7f78ff07b0220686cd6e4658ac30c076b62339e2ba67c9a523a3aa15a013c3b12a0cfe66f7861012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffff1a8dbbbc32c6803851d34478dccd71b80112be9f784f688c83f857098ca129a3030000006a47304402201c3514587ccb5d7642545185a87bc78c6f5c8fef0540896d832dd3c51430c73d02207bced10c07098737202857c5f64b59a9aa6c429f2c09fda6dcbfe9897818ab96012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffff0400000000000000000a6a084f4101000201030058020000000000001976a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac58020000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ace05a0100000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('a329a18c0957f8838c684f789fbe1201b871cddc7844d3513880c632bcbb8d1a', 0).and_return('0100000003e108306761ba736fe622594fa663b5e11a84b9ad89c42958f9e5bb6b29009282010000006b483045022100c3c2a39b14e5b512ee18d2a0a82d3549b1fd680e709913494841bd3ec5ca990b02206adb6dc0e7446de433eabddecc446fd843db875e0f1f274bbcdeb27276174079012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffff9b5b6bbee416ce9c39b15be3405f0f19cbb419ef64cbde7523436913ab90c85c000000006a473044022013c63c04cd7c97db4fd0dda9a10d5e92c1a4b1de8f6fe32f3e64bb3b1a900fa802202c03cb27ba4ae9992cd69899dcd5b56cab1198244605c54eaf67e3e97b16e537012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffffd828fe846b63c61af9c20576705e44e1c34ade6f54e38a4fd673664e0c3058dd010000006a473044022059169fefdd17a0cd76e952da561df0e15175c5110daa7173a741c87d68dcac8c02201a3a5641cde5ec86009d118cfd957e19baede6a000339bfdf50f28b2b17478a7012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffff0400000000000000000a6a084f4101000201040058020000000000001976a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac58020000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac48840100000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('829200296bbbe5f95829c489adb9841ae1b563a64f5922e66f73ba61673008e1', 0).and_return('0100000002d57f29f2ddca6dc2873fd518fc7a30e9071d03e6783dc97aed0b282c793726d6000000006b4830450221009ab8161ca948060bd3ac5f91fb4ad1d6a893f92a404b9223b2494598f586403e02207c57b202e67f27f9a95ab3a675ee897381b32dcf836c6d44e8fb0830d9fb390f012102174620b7c583dc471e04b604fc85f7ae19d161a070af7227ca03edfcb6c4dc4fffffffff08fcc35a4b46b36be2b07b5dc06bb635956597d5ea79b028a0a2f70ae6cf6fd6000000006b483045022100d769e648c9cefeee9d537f519b843de603ab15fc8c47e87e42cba7d9a2e57ad202201072a79259464a0dfbffdd342d3fe9eab36c34f09330334e63e139f11313524c012102174620b7c583dc471e04b604fc85f7ae19d161a070af7227ca03edfcb6c4dc4fffffffff0400000000000000000a6a084f41010002055f0058020000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac58020000000000001976a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788acb8770700000000001976a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('d62637792c280bed7ac93d78e6031d07e9307afc18d53f87c26dcaddf2297fd5', 0).and_return('01000000012851315cad50c97ed7818b0d650d28b871fec92018d34093f15b6f51b75eb967000000006b483045022100d338770cd4d27c58c41fd9a64c3b8870eb9a5c2e2d442dcd260333a8a6dfd81e02202b7c0d40c73211dcfb90513597ecb214455ee20a317ec4827566c213e45f9765012102174620b7c583dc471e04b604fc85f7ae19d161a070af7227ca03edfcb6c4dc4fffffffff0358020000000000001976a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788ac0000000000000000096a074f410100016400d8180f00000000001976a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('67b95eb7516f5bf19340d31820c9fe71b8280d650d8b81d77ec950ad5c315128', 0).and_return('01000000011dbc554fc3cef8d23f0babf91511a8d57636a30d009fcbfa0c1bf2ec3e6eb14e00000000fd5e0100483045022100a51f0f0854c44c4b0093c17e249993709834450c84101bec301985d4a1bf11150220160d2af398e33c4dabe0c1f6f047a86f395af3b4ebdd36e366a93af15ee03b8e01483045022100b6ba03760def0187c356d26bd8965f6da4ca1ca14cd61b32a5604739f173e11102207a407443003ac717a7252de1d78962ec98a59b2195399c017a93e63eabdb810f014cc95241044e98d655cb2a16869585afea317fd95e8c1d785c337bca950f9d8190dd53b9f838f69970cbf52b14d4729dab380a8ebbd5e5acc0de426efc835334771c4e0c5d4104c96d495bfdd5ba4145e3e046fee45e84a8a48ad05bd8dbb395c011a32cf9f880326dbd66c140b50257f9618173833b50b6e829b5cd04ffd0ba693b90be8043594104feee534cc0d317cd8abf366bf1f3f93d098585fc5d3d61a22d3020c6d7a9ab6c83a201073e9f45b9a533a5930f421e49ccb760cce77a939032b24c03cb2b8bb153aeffffffff0240420f00000000001976a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788ace81e1c050000000017a91401882b7530c6ba31f88c99580710cbbbd5e228208700000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('d66fcfe60af7a2a028b079ead597659535b66bc05d7bb0e26bb3464b5ac3fc08', 0).and_return('01000000019b5b6bbee416ce9c39b15be3405f0f19cbb419ef64cbde7523436913ab90c85c010000006b483045022100d5233595a3140827c3cfe449cd83520c4004fbd2ae70ee045870d1ae6f55bb8002206bafacf5bacf569873c9e849f24320a304e3e154f9ae50a1bf6f42380337483d0121027a52cac614ba31c0352dfe937cfaaa3ed26312c50b1cbad928894bb3fc9e6655ffffffff0220a10700000000001976a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788ac38f40600000000001976a914753fbfea75311b07c17bbabed46711f039635d0588ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('5cc890ab1369432375decb64ef19b4cb190f5f40e35bb1399cce16e4be6b5b9b', 0).and_return('0100000001d57f29f2ddca6dc2873fd518fc7a30e9071d03e6783dc97aed0b282c793726d6020000006a47304402203b5b3462658f4bb6f2b29053e10ca9e2f418af3d23345323d1cb5907d0f0476e02206a64d2af924bdf1797eff1cb1756c1906fed43de09621deacdc009c6569792e5012102174620b7c583dc471e04b604fc85f7ae19d161a070af7227ca03edfcb6c4dc4fffffffff0210270000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac90c30e00000000001976a914d9018802c2f28b01b9d976f4a77e295babf79ecf88ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('dd58300c4e6673d64f8ae3546fde4ac3e1445e707605c2f91ac6636b84fe28d8', 0).and_return('01000000018acea6b66f0c7d0da3a4e035724c71d798fd80cb971f0ea598482441ec93b021000000006b483045022100e39412857cf32417205eb1b647fb966244199f271996b68e592421b2b6598a6f022065d1245772886d693806b5629f7bc2ef9bb7a5a73732683acdf79f701336b958012103e5e18bb71cab9a0f3e4a8d86eddc8e28a10792ef1f1114e59c57165ed1085355ffffffff02b64d0300000000001976a91484a14fd7c4c522d59158f91f78c250278f66a89988aca0860100000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('44bf414521d4a0deb60dada4ac0bd9823286d8269cb9c074add3a6844bfa42df', 0).and_return('0100000002daf4aac18a09390ba73aa0a905e13c55d721e6b133d4a3fd352506803e99020c010000006a473044022005cc3cb8b9836bffeda462246f04568bff00b54b4c39cc958aba45c322caa6e102206c6611b89b958e05f3a6e0b274078145e907d4ecd7b8e3c31717efb918846ed3012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffffbbc88ecebb508c2fccd29d9f0e76d059bb532c208531ea33c0053013fefdf597030000006a47304402200e63bef956ee05751faf4e2d7dd82d626905ee34d9652d551557b222045a0a8c02201610d427d9a2dfdbbb238d2769a14803549c312e0aef06620fef5f421c8698ab012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffff0400000000000000000a6a084f4101000201180058020000000000001976a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac58020000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988aca8de0000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('0c02993e80062535fda3d433b1e621d7553ce105a9a03aa70b39098ac1aaf4da', 0).and_return('0100000002e108306761ba736fe622594fa663b5e11a84b9ad89c42958f9e5bb6b29009282020000006b483045022100f1a3e4ec6a5939eeb046cfea51f55f576cf4a21290df1158453c56ca216643c902207ec9f93e57c98244fb6ab334af83c03ae96036a155fa6e30e268959d3fcea8b5012102174620b7c583dc471e04b604fc85f7ae19d161a070af7227ca03edfcb6c4dc4fffffffffe108306761ba736fe622594fa663b5e11a84b9ad89c42958f9e5bb6b29009282030000006b483045022100a8cf4a7eed5e8f0d8d11404ab395100440af34289c32d9d4671d0d6bf71065e0022021b9cbb13a7acc38457bb35028914ddcfbea3034c74ee87c01df5e36089bacb6012102174620b7c583dc471e04b604fc85f7ae19d161a070af7227ca03edfcb6c4dc4fffffffff0400000000000000000a6a084f4101000219460058020000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac58020000000000001976a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788ac504e0700000000001976a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('97f5fdfe133005c033ea3185202c53bb59d0760e9f9dd2cc2f8c50bbce8ec8bb', 0).and_return('0100000002a36a2a6126cefc3725e6e280f8879a16ec8f175cd65b3d299ce27a15fb8bba3f020000006a4730440220765588e8dc5ccbd444d5718d44ee4327ab641aab3b7ca3e961c622517cec25d4022050fdbab13690df66c60e76e9846a79b28f927345492743e24573e2a4db823269012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffffa36a2a6126cefc3725e6e280f8879a16ec8f175cd65b3d299ce27a15fb8bba3f030000006a47304402204bc6f61dc18a925711cd4a98ff0290b6deb6b74cfe3a1748b63dba8b7ec41cdb0220748e312eb4c9dfec8f753cddf5746afc9fb7209cff831bd03bfaf1ade0e40b33012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffff0400000000000000000a6a084f4101000201010058020000000000001976a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac58020000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac10080100000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('7bf10738ab63989d3c7b34ce5ee610bb4b6ff1ffab0f203d60f4089bd62f3984', 0).and_return('010000000225effeede01fed5009223f137487e8f553635117f6a4c8e2a82212599ff28283010000006a47304402202e2c4fcf0e0df5817ba73cf7073d711e52df66f331aba7c8dc7bdcd4b1db4f8702204e124f78140f0bafc3776d0f8a593674699fe553f4906bd2116d198c06928c8e012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffff4d2ddf7930b6f4f26d825163fecd24eecc0d1749b24a263734b053661e54a59d030000006b483045022100e7596bc109eead32f4164a128fa329fe0c5ff95093a97c11cf10e3072eea5472022033ade6fb6e5e6a2d15a5b5cd1771e1b63a25bb5a165056c9673c1a730ece1d08012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffff030000000000000000096a074f41010001010058020000000000001976a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac308e0000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('8382f29f591222a8e2c8a4f617516353f5e88774133f220950ed1fe0edfeef25', 0).and_return('0100000002601c8e18d88537c1bae0691c0d8b768c952b4402b114d5964f692c140d719a8e020000006a47304402204499758dab8e117c40f640de25f2a487989be277a84c54a2fe027914ec4d2a59022079641263d4463d821802af282ff3c3a30ebf0e68c77f6027c8b1d00eebe1ca6a012102174620b7c583dc471e04b604fc85f7ae19d161a070af7227ca03edfcb6c4dc4fffffffff601c8e18d88537c1bae0691c0d8b768c952b4402b114d5964f692c140d719a8e030000006b483045022100bedf89e7302f8e2cc4ce5c4f8fd31ee0093e362a348df197c30725ece485bca702206605a643f16da53ce72a13c22b98166e4eeb7fcb8e744c415c2b514b35b54a77012102174620b7c583dc471e04b604fc85f7ae19d161a070af7227ca03edfcb6c4dc4fffffffff0400000000000000000a6a084f4101000201440058020000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac58020000000000001976a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788ac80fb0600000000001976a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('8e9a710d142c694f96d514b102442b958c768b0d1c69e0bac13785d8188e1c60', 0).and_return('0100000002daf4aac18a09390ba73aa0a905e13c55d721e6b133d4a3fd352506803e99020c020000006a47304402204fc5339a84a2cb85d8dbc5692401ddcddc0f7ceda094d58019c1b1e0725d616502207c416e182a0d40216898db84d76e07e8ef37086dabf16a86d0522357de4dbe06012102174620b7c583dc471e04b604fc85f7ae19d161a070af7227ca03edfcb6c4dc4fffffffffdaf4aac18a09390ba73aa0a905e13c55d721e6b133d4a3fd352506803e99020c030000006a4730440220652824656888d25ca13d5badcea616b83fa260391a83467ba0b2c9e827eef07e0220435851f746b6a6948d8b3692015ce83c2eeb41ba898fcfafefa530b0e4af2ad4012102174620b7c583dc471e04b604fc85f7ae19d161a070af7227ca03edfcb6c4dc4fffffffff0400000000000000000a6a084f4101000201450058020000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac58020000000000001976a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788ace8240700000000001976a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('9da5541e6653b03437264ab249170dccee24cdfe6351826df2f4b63079df2d4d', 0).and_return('0100000002df42fa4b84a6d3ad74c0b99c26d8863282d90baca4ad0db6dea0d4214541bf44020000006b483045022100d413ee31386cf803c0018f4156299c302b0093b7244271b1c951ab8372c66b1e022005d8c1ec186624c6f2880064c5b698f8a0bf57855a8eb5f379c3e1ea7ba5aa3a012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffffdf42fa4b84a6d3ad74c0b99c26d8863282d90baca4ad0db6dea0d4214541bf44030000006b48304502210085464bcf5b32efc3cbfe760a7679995d52cc0e3c2b978f0645c42d28023f16a602201b60c25685c43048a583da37f01a53decd5f1820c3cf026753faa4830ae47ef3012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffff0400000000000000000a6a084f4101000201170058020000000000001976a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac58020000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac40b50000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('92ecb6c38bfefc3b6ff8b48a2dd14ece823d37c02adbeeeeede5a801e4926ece', 0).and_return('0100000002601c8e18d88537c1bae0691c0d8b768c952b4402b114d5964f692c140d719a8e010000006a4730440220013d9250bd071fff47d9a348acbf032a599df75172ce5c99e7037744e85e5ae90220362d35615d325aaf1e8780659fea03e8e7d4a1a277b33870cf383631c2d6206c012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffff84392fd69b08f4603d200fabfff16f4bbb10e65ece347b3c9d9863ab3807f17b020000006b4830450221009db1641290041a3578e6928a6b9a76c40cb3912f98677b2fbdccc9e2988a4a1802201819f8e3da8edc6012397290c29fefede2b749cc97474f9cfea30bba86217e2b012102544912ce55bcab484f5d2ba0f54c420160f37c3978b68b0fa67cc92417739b3effffffff030000000000000000096a074f41010001010058020000000000001976a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac20670000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('b8d52b6452a7e282a656e81dfa21b30d6bd8ce1150c73b89b33f11eed7cff096', 0).and_return('01000000025d53e981c88c55a38e88cac043b5fb6be2ab384577db99ef9aa9092cac7383f9000000006a47304402200a20a051cd2e96be851c85bafed18157529deec625a300acc2f1c3090d9627f502206c25f6ab641f2117dc3e1e03c6db11e89741030956a68905390c237013024ff801210233df159fad83540209cd32ad761893d90119354b40dad24c481b6c1f8e39cd8bffffffff5d53e981c88c55a38e88cac043b5fb6be2ab384577db99ef9aa9092cac7383f9020000006b483045022100de33c1bc49f6aaf00dd2b9513359ab68e5b0629e9c8c2c9371845938d058f34e02204dea9902cd6dd53f4db4c16b0b71e89d1919e4fd6938b717f7ce444b4654671601210233df159fad83540209cd32ad761893d90119354b40dad24c481b6c1f8e39cd8bffffffff0400000000000000000b6a094f4101000243990b0058020000000000001976a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac58020000000000001976a9147cbc38b45e36dbe96e991d737450f047a9899a6388ac504e0700000000001976a9147cbc38b45e36dbe96e991d737450f047a9899a6388ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('f98373ac2c09a99aef99db774538abe26bfbb543c0ca888ea3558cc881e9535d', 0).and_return('01000000017d0cb5a3201f4b9585a3b4bb0347b21c603a2fee95c5de56ee5b0834b49e1452000000006a473044022037bbfc19ea97d773e196d57bf13bd089041180c2a6f18768d9cba5f161a090120220707ed82a8d175b306af33db7b4e56dacb0946885fd5a4c414d1885926c5c78e801210233df159fad83540209cd32ad761893d90119354b40dad24c481b6c1f8e39cd8bffffffff0358020000000000001976a9147cbc38b45e36dbe96e991d737450f047a9899a6388ac0000000000000000206a1e4f41010001dc0b16753d687474703a2f2f676f6f2e676c2f6653346d456ab8770700000000001976a9147cbc38b45e36dbe96e991d737450f047a9899a6388ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('52149eb434085bee56dec595ee2f3a601cb24703bbb4a385954b1f20a3b50c7d', 0).and_return('0100000002d828fe846b63c61af9c20576705e44e1c34ade6f54e38a4fd673664e0c3058dd000000006b483045022100ae213bed8880c72aaa345d83de4a544675fbe8f0ea9e2ea002e6e16986560bca02206c7499383d958f42a2a1b1e4daeadee9928c693dbd6ad51622709a89df4cf8cc012103a53d2d96e090615d19b2e47078eb79434c1cb9555ac588b05170a715619a40a2ffffffff0471efecafcbed89444b171b303fbc73d2c4986be507121f4efe40ba0e5bb5d2030000006b483045022100aff08b10ecef5ee5f165af4494b171db48d06c0cd76f84eb8f952a5d866084ff02206c559534f1c566b8a59286b90ea1291f319fa91f70cd0bd6cef67304b6e939ca012102174620b7c583dc471e04b604fc85f7ae19d161a070af7227ca03edfcb6c4dc4fffffffff0220a10700000000001976a9147cbc38b45e36dbe96e991d737450f047a9899a6388ac9b090000000000001976a914d168cfcf5bd060b4a92a0b26cb0456c2c468fc0588ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('950a882a74bd2fd4f287090f0c467d144f832388898914d198bb03f2cc612f6e', 0).and_return('010000000130fb1d774e51998e33a37ca2b0ab895f97148891d152f3c2f2c508f1a772abf2000000006b483045022100a73b9f64f47ab8d85d00b3f98fbe047080a62a1392cfdc46f229cbca40c60cf80220028f064b3cb3294f96d0751713c355e0185cbdf86f1c65f8d3a1015f71151c93012102fada989e132f5c7002c18c7fa6971f6c214d634eeb9b6d86077a63708cb66776ffffffff0358020000000000001976a914878bd346b688c798eeeff329c6ffafddddbaa0f288ac0000000000000000206a1e4f41010001d00f16753d687474703a2f2f676f6f2e676c2f6653346d456a385d0100000000001976a914878bd346b688c798eeeff329c6ffafddddbaa0f288ac00000000')
    allow(btc_provider_mock).to receive(:get_transaction).with('f2ab72a7f108c5f2c2f352d1918814975f89abb0a27ca3338e99514e771dfb30', 0).and_return('010000000196f0cfd7ee113fb3893bc75011ced86b0db321fa1de856a682e2a752642bd5b8030000006b48304502201c4dfcd9700a7af62a0e242b15bca0d6ab0a7e58a1a5b2673d314a7fe56506ae022100be488d23438044c598111735b7f5cfb657c9e826965de6832de2c4748ad441a701210233df159fad83540209cd32ad761893d90119354b40dad24c481b6c1f8e39cd8bffffffff02a0860100000000001976a914878bd346b688c798eeeff329c6ffafddddbaa0f288ac0af00200000000001976a91461879103f4db4f02b6dc9ba641bb3a29855fa8aa88ac00000000')
  end

  BTC_UNSPENT = [
      {"txid" => "21b093ec41244898a50e1f97cb80fd98d7714c7235e0a4a30d7d0c6fb6a6ce8a",
       "vout" => 1,
       "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
       "account" => "shop1@haw.co.jp",
       "scriptPubKey" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
       "amount" => 0.00100000,
       "confirmations" => 5848,
       "spendable" => true
      },
      {
          "txid" => "3fba8bfb157ae29c293d5bd65c178fec169a87f880e2e62537fcce26612a6aa3",
          "vout" => 1,
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "account" => "shop1@haw.co.jp",
          "scriptPubKey" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "amount" => 0.00000600,
          "confirmations" => 5799,
          "spendable" => true
      },
      {
          "txid" => "44bf414521d4a0deb60dada4ac0bd9823286d8269cb9c074add3a6844bfa42df",
          "vout" => 1,
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "account" => "shop1@haw.co.jp",
          "scriptPubKey" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "amount" => 0.00000600,
          "confirmations" => 5592,
          "spendable" => true
      },
      {
          "txid" => "64873e801b9886af5f5fb30889d816d38f77856544b1233d1491f4bcf9e3062a",
          "vout" => 1,
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "account" => "shop1@haw.co.jp",
          "scriptPubKey" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "amount" => 0.00000600,
          "confirmations" => 5812,
          "spendable" => true
      },
      {
          "txid" => "7bf10738ab63989d3c7b34ce5ee610bb4b6ff1ffab0f203d60f4089bd62f3984",
          "vout" => 1,
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "account" => "shop1@haw.co.jp",
          "scriptPubKey" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "amount" => 0.00000600,
          "confirmations" => 5532,
          "spendable" => true
      },
      {
          "txid" => "8382f29f591222a8e2c8a4f617516353f5e88774133f220950ed1fe0edfeef25",
          "vout" => 2,
          "address" => "1MFW7BTwiNbAkmVz4SzAMQXboKYKGSzkq2",
          "account" => "admin@haw.co.jp",
          "scriptPubKey" => "76a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788ac",
          "amount" => 0.00000600,
          "confirmations" => 5728,
          "spendable" => true
      },
      {
          "txid" => "8382f29f591222a8e2c8a4f617516353f5e88774133f220950ed1fe0edfeef25",
          "vout" => 3,
          "address" => "1MFW7BTwiNbAkmVz4SzAMQXboKYKGSzkq2",
          "account" => "admin@haw.co.jp",
          "scriptPubKey" => "76a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788ac",
          "amount" => 0.00457600,
          "confirmations" => 5728,
          "spendable" => true
      },
      {
          "txid" => "92ecb6c38bfefc3b6ff8b48a2dd14ece823d37c02adbeeeeede5a801e4926ece",
          "vout" => 1,
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "account" => "shop1@haw.co.jp",
          "scriptPubKey" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "amount" => 0.00000600,
          "confirmations" => 5532,
          "spendable" => true
      },
      {
          "txid" => "92ecb6c38bfefc3b6ff8b48a2dd14ece823d37c02adbeeeeede5a801e4926ece",
          "vout" => 2,
          "address" => "1HhJs3JgbiyxC8ktfi6nU4wTqVmrMtCVkG",
          "account" => "info@haw.co.jp",
          "scriptPubKey" => "76a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac",
          "amount" => 0.00026400,
          "confirmations" => 5532,
          "spendable" => true
      },
      {
          "txid" => "97f5fdfe133005c033ea3185202c53bb59d0760e9f9dd2cc2f8c50bbce8ec8bb",
          "vout" => 1,
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "account" => "shop1@haw.co.jp",
          "scriptPubKey" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "amount" => 0.00000600,
          "confirmations" => 5798,
          "spendable" => true
      },
      {
          "txid" => "97f5fdfe133005c033ea3185202c53bb59d0760e9f9dd2cc2f8c50bbce8ec8bb",
          "vout" => 2,
          "address" => "1HhJs3JgbiyxC8ktfi6nU4wTqVmrMtCVkG",
          "account" => "info@haw.co.jp",
          "scriptPubKey" => "76a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac",
          "amount" => 0.00000600,
          "confirmations" => 5798,
          "spendable" => true
      },
      {
          "txid" => "9da5541e6653b03437264ab249170dccee24cdfe6351826df2f4b63079df2d4d",
          "vout" => 1,
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "account" => "shop1@haw.co.jp",
          "scriptPubKey" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "amount" => 0.00000600,
          "confirmations" => 5592,
          "spendable" => true
      },
      {
          "txid" => "9da5541e6653b03437264ab249170dccee24cdfe6351826df2f4b63079df2d4d",
          "vout" => 2,
          "address" => "1HhJs3JgbiyxC8ktfi6nU4wTqVmrMtCVkG",
          "account" => "info@haw.co.jp",
          "scriptPubKey" => "76a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac",
          "amount" => 0.00000600,
          "confirmations" => 5592,
          "spendable" => true
      },
      {
          "txid" => "a329a18c0957f8838c684f789fbe1201b871cddc7844d3513880c632bcbb8d1a",
          "vout" => 1,
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "account" => "shop1@haw.co.jp",
          "scriptPubKey" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "amount" => 0.00000600,
          "confirmations" => 5814,
          "spendable" => true
      },
      {
          "txid" => "dd58300c4e6673d64f8ae3546fde4ac3e1445e707605c2f91ac6636b84fe28d8",
          "vout" => 0,
          "address" => "1D6HSU9CcWyyaiBjFxWWPgVhDcwkMMn4jk",
          "scriptPubKey" => "76a91484a14fd7c4c522d59158f91f78c250278f66a89988ac",
          "amount" => 0.00216502,
          "confirmations" => 5815,
          "spendable" => true
      }
  ]

  OA_UNSPENT = [
      {
          "script" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "asset_quantity" => "0",
          "vout" => 1,
          "amount" => "0.00100000",
          "oa_address" => "akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH",
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "txid" => "21b093ec41244898a50e1f97cb80fd98d7714c7235e0a4a30d7d0c6fb6a6ce8a",
          "asset_id" => nil,
          "confirmations" => 5848
      },
      {
          "script" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "asset_quantity" => "1",
          "vout" => 1,
          "amount" => "0.00000600",
          "oa_address" => "akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH",
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "txid" => "3fba8bfb157ae29c293d5bd65c178fec169a87f880e2e62537fcce26612a6aa3",
          "asset_id" => "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
          "confirmations" => 5799
      },
      {
          "script" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "asset_quantity" => "1",
          "vout" => 1,
          "amount" => "0.00000600",
          "oa_address" => "akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH",
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "txid" => "44bf414521d4a0deb60dada4ac0bd9823286d8269cb9c074add3a6844bfa42df",
          "asset_id" => "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
          "confirmations" => 5592
      },
      {
          "script" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "asset_quantity" => "1",
          "vout" => 1,
          "amount" => "0.00000600",
          "oa_address" => "akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH",
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "txid" => "64873e801b9886af5f5fb30889d816d38f77856544b1233d1491f4bcf9e3062a",
          "asset_id" => "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
          "confirmations" => 5812
      },
      {
          "script" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "asset_quantity" => "1",
          "vout" => 1,
          "amount" => "0.00000600",
          "oa_address" => "akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH",
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "txid" => "7bf10738ab63989d3c7b34ce5ee610bb4b6ff1ffab0f203d60f4089bd62f3984",
          "asset_id" => "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
          "confirmations" => 5532
      },
      {
          "script" => "76a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788ac",
          "asset_quantity" => "68",
          "vout" => 2,
          "amount" => "0.00000600",
          "oa_address" => "akXDPMMHHBrUrd1fM756M1GSB8viVAwMyBk",
          "address" => "1MFW7BTwiNbAkmVz4SzAMQXboKYKGSzkq2",
          "txid" => "8382f29f591222a8e2c8a4f617516353f5e88774133f220950ed1fe0edfeef25",
          "asset_id" => "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
          "confirmations" => 5728
      },
      {
          "script" => "76a914de20a2d5a57ee40ce9a4ce14cf06a6c2c6ffe29788ac",
          "asset_quantity" => "0",
          "vout" => 3,
          "amount" => "0.00457600",
          "oa_address" => "akXDPMMHHBrUrd1fM756M1GSB8viVAwMyBk",
          "address" => "1MFW7BTwiNbAkmVz4SzAMQXboKYKGSzkq2",
          "txid" => "8382f29f591222a8e2c8a4f617516353f5e88774133f220950ed1fe0edfeef25",
          "asset_id" => nil,
          "confirmations" => 5728
      },
      {
          "script" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "asset_quantity" => "1",
          "vout" => 1,
          "amount" => "0.00000600",
          "oa_address" => "akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH",
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "txid" => "92ecb6c38bfefc3b6ff8b48a2dd14ece823d37c02adbeeeeede5a801e4926ece",
          "asset_id" => "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
          "confirmations" => 5532
      },
      {
          "script" => "76a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac",
          "asset_quantity" => "0",
          "vout" => 2,
          "amount" => "0.00026400",
          "oa_address" => "akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6",
          "address" => "1HhJs3JgbiyxC8ktfi6nU4wTqVmrMtCVkG",
          "txid" => "92ecb6c38bfefc3b6ff8b48a2dd14ece823d37c02adbeeeeede5a801e4926ece",
          "asset_id" => nil,
          "confirmations" => 5532
      },
      {
          "script" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "asset_quantity" => "1",
          "vout" => 1,
          "amount" => "0.00000600",
          "oa_address" => "akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH",
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "txid" => "97f5fdfe133005c033ea3185202c53bb59d0760e9f9dd2cc2f8c50bbce8ec8bb",
          "asset_id" => "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
          "confirmations" => 5798
      },
      {
          "script" => "76a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac",
          "asset_quantity" => "1",
          "vout" => 2,
          "amount" => "0.00000600",
          "oa_address" => "akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6",
          "address" => "1HhJs3JgbiyxC8ktfi6nU4wTqVmrMtCVkG",
          "txid" => "97f5fdfe133005c033ea3185202c53bb59d0760e9f9dd2cc2f8c50bbce8ec8bb",
          "asset_id" => "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
          "confirmations" => 5798
      },
      {
          "script" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "asset_quantity" => "1",
          "vout" => 1,
          "amount" => "0.00000600",
          "oa_address" => "akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH",
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "txid" => "9da5541e6653b03437264ab249170dccee24cdfe6351826df2f4b63079df2d4d",
          "asset_id" => "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
          "confirmations" => 5592
      },
      {
          "script" => "76a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac",
          "asset_quantity" => "23",
          "vout" => 2,
          "amount" => "0.00000600",
          "oa_address" => "akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6",
          "address" => "1HhJs3JgbiyxC8ktfi6nU4wTqVmrMtCVkG",
          "txid" => "9da5541e6653b03437264ab249170dccee24cdfe6351826df2f4b63079df2d4d",
          "asset_id" => "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
          "confirmations" => 5592
      },
      {
          "script" => "76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac",
          "asset_quantity" => "1",
          "vout" => 1,
          "amount" => "0.00000600",
          "oa_address" => "akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH",
          "address" => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          "txid" => "a329a18c0957f8838c684f789fbe1201b871cddc7844d3513880c632bcbb8d1a",
          "asset_id" => "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
          "confirmations" => 5814
      },
      {
          "script" => "76a91484a14fd7c4c522d59158f91f78c250278f66a89988ac",
          "asset_quantity" => "0",
          "vout" => 0,
          "amount" => "0.00216502",
          "oa_address" => "akP4AgdxY5zsfSxM6Jach3YQGZE7vM1o8si",
          "address" => "1D6HSU9CcWyyaiBjFxWWPgVhDcwkMMn4jk",
          "txid" => "dd58300c4e6673d64f8ae3546fde4ac3e1445e707605c2f91ac6636b84fe28d8",
          "asset_id" => nil,
          "confirmations" => 5815
      }
  ]

  OA_BALANCE = [
      {
          :oa_address => "akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH",
          :assets => [
              {
                  :asset_id => "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
                  :quantity => "8"
              }
          ],
          :address => "14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6",
          :value => "0.00104800"
      },
      {
          :oa_address => "akP4AgdxY5zsfSxM6Jach3YQGZE7vM1o8si",
          :assets => [],
          :address => "1D6HSU9CcWyyaiBjFxWWPgVhDcwkMMn4jk",
          :value => "0.00216502"
      },
      {
          :oa_address => "akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6",
          :assets => [
              {
                  :asset_id => "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
                  :quantity => "24"
              }
          ],
          :address => "1HhJs3JgbiyxC8ktfi6nU4wTqVmrMtCVkG",
          :value => "0.00027600"
      },
      {
          :oa_address => "akXDPMMHHBrUrd1fM756M1GSB8viVAwMyBk",
          :assets => [
              {
                  :asset_id => "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
                  :quantity => "68"
              }
          ],
          :address => "1MFW7BTwiNbAkmVz4SzAMQXboKYKGSzkq2",
          :value => "0.00458200"
      }
  ]

  DIVISIBILITY_UNSPENT = [
      {"txid" => "b8d52b6452a7e282a656e81dfa21b30d6bd8ce1150c73b89b33f11eed7cff096",
       "vout" => 2,
       "address" => "1CNYGeUsJU6csL8ZkZATrJhzmhv7LM4vFx",
       "account" => "divisibility-test",
       "scriptPubKey" => "76a9147cbc38b45e36dbe96e991d737450f047a9899a6388ac",
       "amount" => 0.00000600,
       "confirmations" => 414,
       "spendable" => true
      },
      {"txid" => "b8d52b6452a7e282a656e81dfa21b30d6bd8ce1150c73b89b33f11eed7cff096",
       "vout" => 3,
       "address" => "1CNYGeUsJU6csL8ZkZATrJhzmhv7LM4vFx",
       "account" => "divisibility-test",
       "scriptPubKey" => "76a9147cbc38b45e36dbe96e991d737450f047a9899a6388ac",
       "amount" => 0.00478800,
       "confirmations" => 414,
       "spendable" => true
      },
      {"txid" => "b8d52b6452a7e282a656e81dfa21b30d6bd8ce1150c73b89b33f11eed7cff096",
       "vout" => 1,
       "address" => "1HhJs3JgbiyxC8ktfi6nU4wTqVmrMtCVkG",
       "account" => "info@haw.co.jp",
       "scriptPubKey" => "76a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac",
       "amount" => 0.00000600,
       "confirmations" => 420,
       "spendable" => true
      },
      {"txid" => "950a882a74bd2fd4f287090f0c467d144f832388898914d198bb03f2cc612f6e",
       "vout" => 0,
       "address" => "1DMhj8VLajNUvhzXnZYnX8tgi7bReYeS13",
       "account" => "nvalid-metadata",
       "scriptPubKey" => "76a914878bd346b688c798eeeff329c6ffafddddbaa0f288ac",
       "amount" => 0.00000600,
       "confirmations" => 1,
       "spendable" => true
      }
  ]

end