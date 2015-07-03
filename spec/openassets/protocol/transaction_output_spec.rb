require 'spec_helper'

describe OpenAssets::Protocol::TransactionOutput do

  it "initialize" do
    expect{OpenAssets::Protocol::TransactionOutput.new(
               "", "", "ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC", 100, 10)}.to raise_error(ArgumentError)
    expect(OpenAssets::Protocol::TransactionOutput.new(
        "", "", "ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC", 100,
        OpenAssets::Protocol::OutputType::MARKER_OUTPUT).output_type).to eq(OpenAssets::Protocol::OutputType::MARKER_OUTPUT)
  end

end