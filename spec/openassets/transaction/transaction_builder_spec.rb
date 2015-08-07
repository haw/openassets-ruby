require 'spec_helper'

describe OpenAssets::Transaction::TransactionBuilder do

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
    outputs = OpenAssets::Transaction::TransactionBuilder.collect_uncolored_outputs(unspent_outputs, 2 * 10 + 5)
    expect(outputs.length).to eq(2)
    expect(outputs[0].length).to eq(2)
    expect(outputs[1]).to eq(25)
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

  it 'create uncolored ouput' do
    target = OpenAssets::Transaction::TransactionBuilder.new(10)
    expect{target.send(:create_uncolored_output, '1F2AQr6oqNtcJQ6p9SiCLQTrHuM9en44H8', 9)}.to raise_error(OpenAssets::Transaction::DustOutputError)
    expect(target.send(:create_uncolored_output, '1F2AQr6oqNtcJQ6p9SiCLQTrHuM9en44H8', 11)).to be_a(Bitcoin::Protocol::TxOut)
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