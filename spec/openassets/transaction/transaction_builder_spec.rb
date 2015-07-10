require 'spec_helper'

describe OpenAssets::Transaction::TransactionBuilder do

  it "collect uncolored outputs" do
    unspent_outputs = gen_outputs(
        [[20, 'source', 'ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC', 50],
         [15, 'source', nil, 0],
         [10, 'source', nil, 0]])
    outputs = OpenAssets::Transaction::TransactionBuilder.collect_uncolored_outputs(unspent_outputs, 2 * 10 + 5)
    expect(outputs.length).to eq(2)
    expect(outputs[0].length).to eq(2)
    expect(outputs[1]).to eq(25)
  end

  it "collect uncolored output but insufficient" do
    unspent_outputs = gen_outputs(
        [[20, 'source', 'ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC', 50],
         [15, 'source', 'ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC', 0],
         [10, 'source', nil, 0]])
    expect{
      OpenAssets::Transaction::TransactionBuilder.collect_uncolored_outputs(unspent_outputs, 2 * 10 + 5)
    }.to raise_error(OpenAssets::Transaction::InsufficientFundsError)
  end

  # generate outputs
  # @param [Array[Array]] definitions definition array format = [value, output_script, asset_id, asset_quantity]
  def gen_outputs(definitions)
    results = []
    definitions.each_with_index { |definition, i|
      results << OpenAssets::Transaction::SpendableOutput.new(
          OpenAssets::Transaction::OutPoint.new(["#{i}"].pack("H*") * 32, i),
          OpenAssets::Protocol::TransactionOutput.new(definition[0], # value
                                                      Bitcoin::Script.new(definition[1]), # script
                                                      definition[2], # asset_id
                                                      definition[3]) # asset_quantity
      )
    }
    results
  end

end