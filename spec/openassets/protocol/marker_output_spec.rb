require 'spec_helper'

describe OpenAssets::Protocol::MarkerOutput do

  it "to payload" do
    payload = OpenAssets::Protocol::MarkerOutput.new([10000], "u=https://cpr.sm/5YgSU1Pg-q").to_payload
    expect(payload).to eq('4f41010001904e1b753d68747470733a2f2f6370722e736d2f35596753553150672d71')
  end

  it "deserialize payload" do
    marker_output = OpenAssets::Protocol::MarkerOutput.
        deserialize_payload("4f41010001904e1b753d68747470733a2f2f6370722e736d2f35596753553150672d71")
    expect(marker_output.asset_quantities.length).to eq(1)
    expect(marker_output.asset_quantities[0]).to eq(10000)
    expect(marker_output.metadata).to eq("u=https://cpr.sm/5YgSU1Pg-q")
  end

  it "parse output_script" do
    # OP_RETURN deadbeef (normal bitcoin op_return)
    no_payload = OpenAssets::Protocol::MarkerOutput.parse_script(Bitcoin::Script.new(["6a04deadbeef"].pack("H*")))
    expect(no_payload).to be_nil
    # OP_RETURN 4f41010002014400 (colored coin marker output)
    payload = OpenAssets::Protocol::MarkerOutput.parse_script(Bitcoin::Script.new(["6a084f41010002014400"].pack("H*")))
    expect(payload).to eq("4f41010002014400")
  end

end