require 'spec_helper'

describe OpenAssets::Util do

  let(:test_class) {Struct.new(:util) {include OpenAssets::Util}}
  let(:util) {test_class.new}

  context 'mainnet' do
    it 'convert address ' do
      btc_address = '1F2AQr6oqNtcJQ6p9SiCLQTrHuM9en44H8'
      oa_address = 'akQz3f1v9JrnJAeGBC4pNzGNRdWXKan4U6E'
      expect(util.address_to_oa_address(btc_address)).to eq(oa_address)
      expect(util.oa_address_to_address(oa_address)).to eq(btc_address)
    end

    it 'generate asset ID from public key' do
      expect(util.generate_asset_id(
          '0450863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b23522cd470243453a299fa9e77237716103abc11a1df38855ed6f2ee187e9c582ba6'))
          .to eq('ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC')
    end

    it 'validate asset ID' do
      puts
      expect(util.valid_asset_id?('ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC')).to be true
      expect(util.valid_asset_id?('')).to be false
      expect(util.valid_asset_id?(nil)).to be false
      expect(util.valid_asset_id?('oLn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC')).to be false
      expect(util.valid_asset_id?('ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC3')).to be false
    end
  end

  context 'testnet', :network => :testnet do
    it 'pubkey_hash_to_asset_id' do
      expect(util.pubkey_hash_to_asset_id('081522820f2ccef873e47ee62b31cb9e9267e725')).to eq('oWLkUn44E45cnQtsP6x1wrvJ2iRx9XyFny')
    end

    it 'validate asset ID' do
      puts
      expect(util.valid_asset_id?('oWLkUn44E45cnQtsP6x1wrvJ2iRx9XyFny')).to be true
      expect(util.valid_asset_id?('')).to be false
      expect(util.valid_asset_id?(nil)).to be false
      expect(util.valid_asset_id?('kXiQGL32ybiiZKfznYMAAPQnVy35LRDL7M')).to be false
      expect(util.valid_asset_id?('oXiQGL32ybiiZKfznYMAAPQnVy35LRDL7M1')).to be false
    end
  end

  it 'leb128 encode' do
    expect(util.encode_leb128(300)).to eq('ac02')
  end

  it 'satoshi to coin' do
    expect(util.satoshi_to_coin(100000)).to eq('0.00100000')
  end

  it 'coin to satoshi' do
    expect(util.coin_to_satoshi('0.00100000')).to eq(100000)
  end

  it 'variable integer' do
    expect(util.read_var_integer("fd0000").first).to eq(0)
    expect(util.read_var_integer("fd1100").first).to eq(17)

    expect(util.read_var_integer("fe00000000").first).to eq(0)
    expect(util.read_var_integer("fe11000000").first).to eq(17)
    expect(util.read_var_integer("fe11220000").first).to eq(8721)

    expect(util.read_var_integer("ff0000000000000000").first).to eq(0)
    expect(util.read_var_integer("ff1100000000000000").first).to eq(17)
    expect(util.read_var_integer("ff1122000000000000").first).to eq(8721)
    expect(util.read_var_integer("ff1122334400000000").first).to eq(1144201745)
  end
end