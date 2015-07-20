require 'spec_helper'

describe OpenAssets::Transaction::OutPoint do

  it "initialize success" do
    out_point = OpenAssets::Transaction::OutPoint.new('8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8220', 0)
    expect(out_point.hash).to eq('8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8220')
    expect(out_point.index).to eq(0)
  end

  it "invalid transaction hash" do
    expect{OpenAssets::Transaction::OutPoint.new("", 1)}.to raise_error(ArgumentError)
  end

  it "invalid index" do
    expect{OpenAssets::Transaction::OutPoint.new("\x01" * 32, -1)}.to raise_error(ArgumentError)
  end

end