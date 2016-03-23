require 'spec_helper'
describe OpenAssets::Cache::OutputCache do

  subject{
    OpenAssets::Cache::OutputCache.new(':memory:')
  }

  it 'output cache' do
    txid = '7ed86d1c2824ea14bf8a2fe27202a1d229a4f58db52e2ba1ed13cf36765deaac'
    index = 0
    output = OpenAssets::Protocol::TransactionOutput.new(
        100, Bitcoin::Script.from_string('OP_RETURN 4f41010001904e1b753d68747470733a2f2f6370722e736d2f35596753553150672d71'),
        'AGHhobo7pVQN5fZWqv3rhdc324ryT7qVTB', 200, OpenAssets::Protocol::OutputType::ISSUANCE, 'u=https://goo.gl/Q0NZfe')

    expect(subject.get(txid, index)).to be nil

    subject.put(txid, index, output)

    expect(subject.get(txid, 1)).to be nil

    cached = subject.get(txid, index)

    expect(cached.value).to eq(100)
    expect(cached.script.to_string).to eq('OP_RETURN 4f41010001904e1b753d68747470733a2f2f6370722e736d2f35596753553150672d71')
    expect(cached.asset_id).to eq('AGHhobo7pVQN5fZWqv3rhdc324ryT7qVTB')
    expect(cached.asset_quantity).to eq(200)
    expect(cached.output_type).to eq(OpenAssets::Protocol::OutputType::ISSUANCE)
    expect(cached.metadata).to eq('u=https://goo.gl/Q0NZfe')
  end

end