require 'spec_helper'

describe OpenAssets::Util do

  let(:test_class) {Struct.new(:util) {include OpenAssets::Util}}
  let(:util) {test_class.new}

  it 'convert open assets address' do
    expect(util.address_to_oa_address('1MFW7BTwiNbAkmVz4SzAMQXboKYKGSzkq2')).to eq('akXDPMMHHBrUrd1fM756M1GSB8viVAwMyBk')
  end

  it 'generate asset ID from public key' do
    expect(util.generate_asset_id(
               '0450863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b23522cd470243453a299fa9e77237716103abc11a1df38855ed6f2ee187e9c582ba6'))
      .to eq('ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC')
  end

  it 'leb128 encode' do
    expect(util.encode_leb128(300)).to eq('ac02')
  end
  
  it 'script to address convert' do

  end
end