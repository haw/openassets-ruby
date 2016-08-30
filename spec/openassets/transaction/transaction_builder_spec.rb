require 'spec_helper'

describe OpenAssets::Transaction::TransactionBuilder do
  include OpenAssets::Util

  it 'issue asset success' do
    unspent_outputs = gen_outputs(
        [[20, 'source', 'ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC', 50, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8220'],
         [15, 'source', nil, 0, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8221'],
         [10, 'source', nil, 0, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8222']])
    target = OpenAssets::Transaction::TransactionBuilder.new(10)
    spec = OpenAssets::Transaction::TransferParameters.new(
        unspent_outputs,
        'akD71LJfDrVkPUg7dSZq6acdeDqgmHjrc2Q',
        'akD71LJfDrVkPUg7dSZq6acdeDqgmHjrc2Q', 1000)
    result = target.issue_asset(spec, 'metadata', 5)
    expect(result.in.length).to eq(2)
    expect(result.out.length).to eq(3)
    in0 = result.in[0]
    expect(in0.prev_out.reverse_hth).to eq('8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8221')
    expect(in0.prev_out_index).to eq(1)
    expect(in0.script_sig).to eq('source')
    in1 = result.in[1]
    expect(in1.prev_out.reverse_hth).to eq('8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8222')
    expect(in1.prev_out_index).to eq(2)
    expect(in1.script_sig).to eq('source')
    # Asset issued
    out0 = result.out[0]
    expect(out0.value).to eq(10)
    expect(Bitcoin::Script.new(out0.pk_script).to_string).to eq('OP_DUP OP_HASH160 17797f19075a56e7d4fc23f2ea5c17020fd3b93d OP_EQUALVERIFY OP_CHECKSIG')
    # Marker output
    out1 = result.out[1]
    payload = OpenAssets::Protocol::MarkerOutput.parse_script(out1.pk_script)
    marker_output = OpenAssets::Protocol::MarkerOutput.deserialize_payload(payload)
    expect(out1.value).to eq(0)
    expect(marker_output.asset_quantities).to eq([1000])
    expect(marker_output.metadata).to eq('metadata')
    # Bitcoin change
    out2 = result.out[2]
    expect(out2.value).to eq(10)
    expect(Bitcoin::Script.new(out2.pk_script).to_string).to eq('OP_DUP OP_HASH160 17797f19075a56e7d4fc23f2ea5c17020fd3b93d OP_EQUALVERIFY OP_CHECKSIG')
  end

  it 'collect uncolored outputs' do
    unspent_outputs = gen_outputs(
        [[20, 'source', 'ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC', 50, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8220'],
         [15, 'source', nil, 0, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8221'],
         [10, 'source', nil, 0, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8222']])
    outputs, amount  = OpenAssets::Transaction::TransactionBuilder.collect_uncolored_outputs(unspent_outputs, 2 * 10 + 5)
    expect(outputs.length).to eq(2)
    outputs.each{|o|expect(o.output.asset_id).to eq(nil)}
    expect(amount).to eq(25)
  end

  it 'collect uncolored output but insufficient' do
    unspent_outputs = gen_outputs(
        [[20, 'source', 'ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC', 50, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8220'],
         [15, 'source', 'ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC', 0, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8221'],
         [10, 'source', nil, 0, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8222']])
    expect{
      OpenAssets::Transaction::TransactionBuilder.collect_uncolored_outputs(unspent_outputs, 2 * 10 + 5)
    }.to raise_error(OpenAssets::Transaction::InsufficientFundsError)
  end

  context 'p2pkh address' do
    it 'create uncolored output' do
      target = OpenAssets::Transaction::TransactionBuilder.new(10)
      expect{target.send(:create_uncolored_output, '1F2AQr6oqNtcJQ6p9SiCLQTrHuM9en44H8', 9)}.to raise_error(OpenAssets::Transaction::DustOutputError)
      tx_out = target.send(:create_uncolored_output, '1F2AQr6oqNtcJQ6p9SiCLQTrHuM9en44H8', 11)
      expect(tx_out).to be_a(Bitcoin::Protocol::TxOut)
      expect(tx_out.parsed_script.to_string).to eq('OP_DUP OP_HASH160 99ca0870645ebc81abbe0806318efc9ff474e540 OP_EQUALVERIFY OP_CHECKSIG')
    end

    it 'create_colored_output' do
      target = OpenAssets::Transaction::TransactionBuilder.new(10)
      tx_out = target.send(:create_colored_output, '1F2AQr6oqNtcJQ6p9SiCLQTrHuM9en44H8')
      expect(tx_out.parsed_script.to_string).to eq('OP_DUP OP_HASH160 99ca0870645ebc81abbe0806318efc9ff474e540 OP_EQUALVERIFY OP_CHECKSIG')
    end

    it 'collect colored outputs' do
      unspent_outputs = gen_outputs(
          [[20, 'source', 'AVQ1hnBhEyaNPk6sS2kpmav2YkyXqrwoUT', 50, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8220'],
           [15, 'source', 'ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC', 0, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8221'],
           [10, 'source', 'AVQ1hnBhEyaNPk6sS2kpmav2YkyXqrwoUT', 27, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8222']])
      outputs, amount = OpenAssets::Transaction::TransactionBuilder.collect_colored_outputs(unspent_outputs, 'AVQ1hnBhEyaNPk6sS2kpmav2YkyXqrwoUT', 60)
      expect(outputs.length).to eq(2)
      outputs.each{|o|expect(o.output.asset_id).to eq('AVQ1hnBhEyaNPk6sS2kpmav2YkyXqrwoUT')}
      expect(amount).to eq(77)
    end
  end

  context 'p2sh address', :network => :testnet do

    it 'create_uncolored_output' do
      target = OpenAssets::Transaction::TransactionBuilder.new(10)
      tx_out = target.send(:create_uncolored_output, '2MtHrGGHzuiW18MF113xJmZXZ8AuBmbeXo4', 11)
      expect(tx_out.parsed_script.to_string).to eq('OP_HASH160 0b773d2e93630161ea0c9cb6aa80c758d131cf9e OP_EQUAL')
    end

    it 'create_colored_output' do
      target = OpenAssets::Transaction::TransactionBuilder.new(10)
      tx_out = target.send(:create_colored_output, '2MtHrGGHzuiW18MF113xJmZXZ8AuBmbeXo4')
      expect(tx_out.parsed_script.to_string).to eq('OP_HASH160 0b773d2e93630161ea0c9cb6aa80c758d131cf9e OP_EQUAL')
    end
  end

  it 'collect colored outputs but insufficient' do
    unspent_outputs = gen_outputs(
      [[20, 'source', 'AVQ1hnBhEyaNPk6sS2kpmav2YkyXqrwoUT', 50, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8220'],
       [15, 'source', 'ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC', 10, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8221'],
       [10, 'source', 'AVQ1hnBhEyaNPk6sS2kpmav2YkyXqrwoUT', 27, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8222']])
    expect{
      OpenAssets::Transaction::TransactionBuilder.collect_colored_outputs(unspent_outputs, 'ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC', 11)
    }.to raise_error(OpenAssets::Transaction::InsufficientAssetQuantityError)
  end

  it 'otsuri needs collect btc' do
    # Bitcoinのおつりが dust_limit = 600 より少ない場合に、不足分のBitcoinのUTXOを集める
    from = 'akXDPMMHHBrUrd1fM756M1GSB8viVAwMyBk'
    to = 'AVQ1hnBhEyaNPk6sS2kpmav2YkyXqrwoUT'
    unspent_outputs = gen_outputs(
        [[600, 'source', 'AVQ1hnBhEyaNPk6sS2kpmav2YkyXqrwoUT', 50, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8220'],
         [600, 'source', 'ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC', 10, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8221'],
         [600, 'source', 'AVQ1hnBhEyaNPk6sS2kpmav2YkyXqrwoUT', 50, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8222'],
         [10700, 'source', nil, 0, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8223'],
         [800, 'source', nil, 0, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8224'],
         [999988, 'source', nil, 0, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8225']])
    builder = OpenAssets::Transaction::TransactionBuilder.new(600)
    spec = OpenAssets::Transaction::TransferParameters.new(unspent_outputs,'akD71LJfDrVkPUg7dSZq6acdeDqgmHjrc2Q', from, 66, 2)
    # 作成されるアウトプット
    # アセット分割送付のアウトプット２つ
    # アセットのおつりのアウトプット１つ
    # BTCのおつりのアウトプット１つ（おつり額＝ 600*2 - 600*3 - 手数料(10000) = -10600）
    # おつり額がマイナスなので、uncoloredなUTXを収集＝10700
    # おつり再計算＝100
    # おつり額がdust_limitより低いので再度UTXO収集
    # marker output
    tx = builder.transfer_asset(to, spec, from, 10000)
    expect(tx.in.length).to eq(4)
    expect(tx.out.length).to eq(5)
    payload = OpenAssets::Protocol::MarkerOutput.parse_script(tx.out[0].pk_script)
    marker_output = OpenAssets::Protocol::MarkerOutput.deserialize_payload(payload)
    expect(marker_output.asset_quantities).to eq([33, 33, 34])
    expect(tx.out[1].value).to eq(600)
    expect(tx.out[2].value).to eq(600)
    expect(tx.out[3].value).to eq(600)
    expect(tx.out[4].value).to eq(900)
  end

  it 'multiple address inputs transfer' do
    from = %w(1DLSeqWwHJj3XrmsXQ5QzZZ4LDgp4gRvF7 1HhgpWTatNTb4UK4mm23QVpZKLm1GQTfkX)
    to = '1HXEqrZxXy5nw7Us8ozFZ1Vwx37dGFL5wC'
    change = '1F2AQr6oqNtcJQ6p9SiCLQTrHuM9en44H8'
    asset_id = 'AVQ1hnBhEyaNPk6sS2kpmav2YkyXqrwoUT'

    unspent_outputs_1 = gen_outputs([[1_000, 'source', asset_id, 500, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8220']])
    unspent_outputs_2 = gen_outputs([[1_000, 'source', asset_id, 500, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8221']])
    unspent_outputs_3 = gen_outputs([[3_000, 'source', nil, 0, '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8222']])

    builder = OpenAssets::Transaction::TransactionBuilder.new(1_000)
    asset_transfer_specs = [
      [asset_id, OpenAssets::Transaction::TransferParameters.new(unspent_outputs_1, address_to_oa_address(to), address_to_oa_address(from[0]), 100)],
      [asset_id, OpenAssets::Transaction::TransferParameters.new(unspent_outputs_2, address_to_oa_address(to), address_to_oa_address(from[1]), 100)]
    ]
    btc_transfer_specs = [OpenAssets::Transaction::TransferParameters.new(unspent_outputs_3, nil, change, 0)]
    tx = builder.send(:transfer, asset_transfer_specs, btc_transfer_specs, 0)

    payload = OpenAssets::Protocol::MarkerOutput.parse_script(tx.out[0].pk_script)
    marker_output = OpenAssets::Protocol::MarkerOutput.deserialize_payload(payload)
    expect(marker_output.asset_quantities).to eq([100,400,100,400])
    expect(tx.out[1].parsed_script.get_address).to eq(to)
    expect(tx.out[2].parsed_script.get_address).to eq(from[0])
    expect(tx.out[3].parsed_script.get_address).to eq(to)
    expect(tx.out[4].parsed_script.get_address).to eq(from[1])
    expect(tx.out[5].parsed_script.get_address).to eq(change)
    expect(tx.out[5].value).to eq(1000)
  end

  # generate outputs
  # @param [Array[Array]] definitions definition array format = [value, output_script, asset_id, asset_quantity]
  def gen_outputs(definitions)
    results = []
    definitions.each_with_index { |definition, i|
      results << OpenAssets::Transaction::SpendableOutput.new(
          OpenAssets::Transaction::OutPoint.new(definition[4], i),
          OpenAssets::Protocol::TransactionOutput.new(definition[0], # value
                                                      Bitcoin::Script.new(definition[1]), # script
                                                      definition[2], # asset_id
                                                      definition[3]) # asset_quantity
      )
    }
    results
  end

end