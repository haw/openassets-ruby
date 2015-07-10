require 'spec_helper'

describe OpenAssets::Transaction::OutPoint do

  it "initialize success" do
    out_point = OpenAssets::Transaction::OutPoint.new("\x01" * 32, 0)
    expect(out_point.hash).to eq("\x01" * 32)
    expect(out_point.index).to eq(0)
  end

  it "invalid transaction hash" do
    expect{OpenAssets::Transaction::OutPoint.new("", 1)}.to raise_error(ArgumentError)
  end

  it "invalid index" do
    expect{OpenAssets::Transaction::OutPoint.new("\x01" * 32, -1)}.to raise_error(ArgumentError)
  end

end