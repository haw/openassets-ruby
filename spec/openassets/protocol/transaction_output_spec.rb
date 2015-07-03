require 'spec_helper'

describe OpenAssets::Protocol::TransactionOutput do

  it "initialize" do
    target = OpenAssets::Protocol::TransactionOutput.new(
        100, "abcd", "ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC", 9223372036854775807,
        OpenAssets::Protocol::OutputType::MARKER_OUTPUT)
    expect(target.output_type).to eq(OpenAssets::Protocol::OutputType::MARKER_OUTPUT)
    expect(target.asset_quantity).to eq(9223372036854775807)
    expect(target.asset_id).to eq("ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC")
    expect(target.script).to eq("abcd")
    expect(target.value).to eq(100)
  end

  it "invalid output type." do
    expect{OpenAssets::Protocol::TransactionOutput.new(
        100, "", "ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC", 100, 10)}.to raise_error(ArgumentError)
  end

  it "invalid asset quantity" do
    expect{OpenAssets::Protocol::TransactionOutput.new(
        100, "", "ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC", 9223372036854775808, 1)}.to raise_error(ArgumentError)
  end

end