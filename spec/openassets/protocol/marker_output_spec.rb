require 'spec_helper'

describe OpenAssets::Protocol::MarkerOutput do

  it "to payload" do
    payload = OpenAssets::Protocol::MarkerOutput.new([5, 300], "abcdef").to_payload
    # expect(payload).to eq('4f4101000205ac0206abcdef')
  end

end