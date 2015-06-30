require 'spec_helper'

describe OpenAssets::Protocol::MarkerOutput do

  it "to payload" do
    payload = OpenAssets::Protocol::MarkerOutput.new([10000], "u=https://cpr.sm/5YgSU1Pg-q").to_payload
    expect(payload).to eq('4f41010001904e1b753d68747470733a2f2f6370722e736d2f35596753553150672d71')
  end

end