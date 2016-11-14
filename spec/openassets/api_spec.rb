require 'spec_helper'

describe 'OpenAssets::Api use mainnet' do

  include OpenAssets::Util

  it 'load configuration' do
    api = OpenAssets::Api.new
    expect(api.is_testnet?).to be false
    expect(api.config[:rpc][:host]).to eq('localhost')
    expect(api.config[:rpc][:port]).to eq(8332)
    expect(api.config[:rpc][:timeout]).to eq(60)
    expect(api.config[:rpc][:open_timeout]).to eq(60)
    expect(api.config[:min_confirmation]).to eq(1)
    expect(api.config[:max_confirmation]).to eq(9999999)
    expect(api.config[:cache]).to eq('cache.db')
    expect(Bitcoin.network_name).to eq(:bitcoin)
    api = OpenAssets::Api.new(JSON.parse(File.read("#{File.dirname(__FILE__)}/../test-config.json"), {:symbolize_names => true}))
    expect(api.is_testnet?).to be true
    expect(Bitcoin.network_name).to eq(:testnet3)
    expect(api.config[:min_confirmation]).to eq(0)
    expect(api.config[:max_confirmation]).to eq(1)
    expect{OpenAssets::Api.new({:provider => 'hoge'})}.to raise_error(OpenAssets::Error)

    OpenAssets::Api.new(:network => 'regtest')
    expect(Bitcoin.network_name).to eq(:regtest)
  end

  context 'use provider' do
    subject {
      btc_provider_mock = double('BitcoinCoreProvider Mock')
      api = OpenAssets::Api.new
      allow(btc_provider_mock).to receive(:list_unspent).and_return(BTC_UNSPENT)
      load_tx_mock(btc_provider_mock)
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
    end

    it 'list_unspent with custom confirmation' do
      expect(subject.provider).to receive(:list_unspent).with([], 1, 9999999)
      subject.list_unspent

      subject.config[:min_confirmation] = 10
      subject.config[:max_confirmation] = 100
      expect(subject.provider).to receive(:list_unspent).with([], 10, 100)
      subject.list_unspent
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
      expect(tx.outputs[3].value).to eq(89400)
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

    it 'get colored outputs from txid' do
      # case for uncolored output
      uncolored = subject.get_outputs_from_txid('21b093ec41244898a50e1f97cb80fd98d7714c7235e0a4a30d7d0c6fb6a6ce8a')
      expect(uncolored.length).to eq(2)
      expect(uncolored[0]['txid']).to eq('21b093ec41244898a50e1f97cb80fd98d7714c7235e0a4a30d7d0c6fb6a6ce8a')
      expect(uncolored[0]['vout']).to eq(0)
      expect(uncolored[0]['address']).to eq('1Q4QP2oqRKCTAhBwKjEm6B56KvjRw2fbMi')
      expect(uncolored[0]['oa_address']).to eq('aka2HdCdAto692wMJNMLwk2yffXubxan81c')
      expect(uncolored[0]['script']).to eq('76a914fcefa84d15d0bf818b020f0cdaf99f4029c15ce788ac')
      expect(uncolored[0]['amount']).to eq('0.00343779')
      expect(uncolored[0]['asset_id']).to eq(nil)
      expect(uncolored[0]['asset_quantity']).to eq('0')
      expect(uncolored[0]['asset_amount']).to eq('0')
      expect(uncolored[0]['account']).to eq(nil)
      expect(uncolored[0]['asset_definition_url']).to eq('')
      expect(uncolored[0]['output_type']).to eq('uncolored')

      expect(uncolored[1]['txid']).to eq('21b093ec41244898a50e1f97cb80fd98d7714c7235e0a4a30d7d0c6fb6a6ce8a')
      expect(uncolored[1]['vout']).to eq(1)
      expect(uncolored[1]['address']).to eq('14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6')
      expect(uncolored[1]['oa_address']).to eq('akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH')
      expect(uncolored[1]['script']).to eq('76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac')
      expect(uncolored[1]['amount']).to eq('0.00100000')
      expect(uncolored[1]['asset_id']).to eq(nil)
      expect(uncolored[1]['asset_quantity']).to eq('0')
      expect(uncolored[1]['asset_amount']).to eq('0')
      expect(uncolored[1]['account']).to eq(nil)
      expect(uncolored[1]['asset_definition_url']).to eq('')
      expect(uncolored[0]['output_type']).to eq('uncolored')

      # case for coloed output
      outputs = subject.get_outputs_from_txid('3fba8bfb157ae29c293d5bd65c178fec169a87f880e2e62537fcce26612a6aa3')
      expect(outputs.length).to eq(4)
      expect(outputs[0]['txid']).to eq('3fba8bfb157ae29c293d5bd65c178fec169a87f880e2e62537fcce26612a6aa3')
      expect(outputs[0]['vout']).to eq(0)
      expect(outputs[0]['address']).to eq(nil)
      expect(outputs[0]['oa_address']).to eq(nil)
      expect(outputs[0]['script']).to eq('6a084f41010002010200')
      expect(outputs[0]['amount']).to eq('0.00000000')
      expect(outputs[0]['asset_id']).to eq(nil)
      expect(outputs[0]['asset_quantity']).to eq('0')
      expect(outputs[0]['asset_amount']).to eq('0')
      expect(outputs[0]['account']).to eq(nil)
      expect(outputs[0]['asset_definition_url']).to eq('')

      expect(outputs[1]['txid']).to eq('3fba8bfb157ae29c293d5bd65c178fec169a87f880e2e62537fcce26612a6aa3')
      expect(outputs[1]['vout']).to eq(1)
      expect(outputs[1]['address']).to eq('14M4kbAtn71P1nnNYuhBDFTNYxa19t1XP6')
      expect(outputs[1]['oa_address']).to eq('akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH')
      expect(outputs[1]['script']).to eq('76a91424b3d405bc60bd9628691fe28bb00f6800e1480688ac')
      expect(outputs[1]['amount']).to eq('0.00000600')
      expect(outputs[1]['asset_id']).to eq('AWo3R89p5REmoSyMWB8AeUmud8456bRxZL')
      expect(outputs[1]['asset_quantity']).to eq('1')
      expect(outputs[1]['asset_amount']).to eq('1')
      expect(outputs[1]['account']).to eq(nil)
      expect(outputs[1]['asset_definition_url']).to eq('')
      expect(outputs[1]['output_type']).to eq('transfer')

      expect(outputs[2]['txid']).to eq('3fba8bfb157ae29c293d5bd65c178fec169a87f880e2e62537fcce26612a6aa3')
      expect(outputs[2]['vout']).to eq(2)
      expect(outputs[2]['address']).to eq('1HhJs3JgbiyxC8ktfi6nU4wTqVmrMtCVkG')
      expect(outputs[2]['oa_address']).to eq('akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6')
      expect(outputs[2]['script']).to eq('76a914b7218fe503cd18555255e5b13d4f07f3fd00d0c988ac')
      expect(outputs[2]['amount']).to eq('0.00000600')
      expect(outputs[2]['asset_id']).to eq('AWo3R89p5REmoSyMWB8AeUmud8456bRxZL')
      expect(outputs[2]['asset_quantity']).to eq('2')
      expect(outputs[2]['asset_amount']).to eq('2')
      expect(outputs[2]['account']).to eq(nil)
      expect(outputs[2]['asset_definition_url']).to eq('')
      expect(outputs[2]['output_type']).to eq('transfer')
    end
  end

  context 'specify oa_address' do
    subject{
      btc_provider_mock = double('BitcoinCoreProvider Mock')
      api = OpenAssets::Api.new
      allow(btc_provider_mock).to receive(:list_unspent).and_return(filter_btc_unspent('1HhJs3JgbiyxC8ktfi6nU4wTqVmrMtCVkG'))
      allow(api).to receive(:provider).and_return(btc_provider_mock)
      api
    }

    it 'list_unspent with args' do
      list = subject.list_unspent(['akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6'])
      expect(list.length).to eq(3)
      list.each{|r|expect(r['oa_address']).to eq('akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6')}
    end

  end

  context 'use provider send asset' do
    subject {
      btc_provider_mock = double('BitcoinCoreProvider Mock')
      api = OpenAssets::Api.new
      allow(btc_provider_mock).to receive(:list_unspent).and_return(filter_btc_unspent('1HhJs3JgbiyxC8ktfi6nU4wTqVmrMtCVkG'))
      load_tx_mock(btc_provider_mock)
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

    it 'send_assets' do
      asset_id = 'AWo3R89p5REmoSyMWB8AeUmud8456bRxZL'
      from = 'akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6'
      to = %w(akP4AgdxY5zsfSxM6Jach3YQGZE7vM1o8si akEJwzkzEFau4t2wjbXoMs7MwtZkB8xixmH)
      params = [
        OpenAssets::SendAssetParam.new(asset_id, 10, to[0]),
        OpenAssets::SendAssetParam.new(asset_id, 10, to[1])
      ]
      tx = subject.send_assets(from, params, 10000, 'unsigned')

      expect(tx.ver).to eq(1)
      expect(tx.lock_time).to eq(0)
      marker_output_payload = OpenAssets::Protocol::MarkerOutput.parse_script(tx.outputs[0].pk_script)
      marker_output = OpenAssets::Protocol::MarkerOutput.deserialize_payload(marker_output_payload)
      expect(tx.outputs.length).to eq(5)
      expect(marker_output.asset_quantities).to eq([10, 10, 4])
      expect(tx.out[1].parsed_script.get_address).to eq(oa_address_to_address to[0])
      expect(tx.out[2].parsed_script.get_address).to eq(oa_address_to_address to[1])
      expect(tx.out[3].parsed_script.get_address).to eq(oa_address_to_address from)
      expect(tx.out[4].parsed_script.get_address).to eq(oa_address_to_address from)

      # multiple from addresses
      from = %w(akTfC7D825Cse4NvFiLCy7vr3B6x2Mpq8t6 akXDPMMHHBrUrd1fM756M1GSB8viVAwMyBk)
      to = 'akP4AgdxY5zsfSxM6Jach3YQGZE7vM1o8si'
      change = to
      params = [
        OpenAssets::SendAssetParam.new(asset_id, 10, to, from[0]),
        OpenAssets::SendAssetParam.new(asset_id, 15, to, from[1])
      ]
      tx = subject.send_assets(change, params, 10000, 'unsigned')

      expect(tx.ver).to eq(1)
      expect(tx.lock_time).to eq(0)
      marker_output_payload = OpenAssets::Protocol::MarkerOutput.parse_script(tx.outputs[0].pk_script)
      marker_output = OpenAssets::Protocol::MarkerOutput.deserialize_payload(marker_output_payload)
      expect(tx.outputs.length).to eq(6)
      expect(marker_output.asset_quantities).to eq([10, 14, 15, 9])
      expect(tx.out[1].parsed_script.get_address).to eq(oa_address_to_address to)
      expect(tx.out[2].parsed_script.get_address).to eq(oa_address_to_address from[0])
      expect(tx.out[3].parsed_script.get_address).to eq(oa_address_to_address to)
      expect(tx.out[4].parsed_script.get_address).to eq(oa_address_to_address from[1])
      expect(tx.out[5].parsed_script.get_address).to eq(oa_address_to_address change)
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
      load_tx_mock(btc_provider_mock)
      allow(api).to receive(:provider).and_return(btc_provider_mock)
      api
    }

    it 'list unspent' do
      unspent = subject.list_unspent(['akNLRWpJCmwzJjaHvoBGeWAca7K6HLgwyvv'])
      expect(unspent[0]['asset_id']).to eq('AJk2Gx5V67S2wNuwTK5hef3TpHunfbjcmX')
      expect(unspent[0]['asset_quantity']).to eq('1433')
      expect(unspent[0]['asset_amount']).to eq('143.3')
      expect(unspent[0]['asset_definition_url']).to eq('http://goo.gl/fS4mEj')
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