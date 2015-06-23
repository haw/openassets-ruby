require 'spec_helper'

describe OpenAssets::Util do

  let(:test_class) {Struct.new(:util) {include OpenAssets::Util}}
  let(:util) {test_class.new}

  it "convert open assets address" do
    expect(util.address_to_oa_address("1MFW7BTwiNbAkmVz4SzAMQXboKYKGSzkq2")).to eq("akXDPMMHHBrUrd1fM756M1GSB8viVAwMyBk")
  end

end