require 'spec_helper'

describe OpenAssets::Protocol::AssetDefinitionLoader, :network => :testnet do

  describe 'initialize' do

    context 'http or https' do
      subject{
        OpenAssets::Protocol::AssetDefinitionLoader.new('http://goo.gl/fS4mEj').loader
      }
      it do
        expect(subject).to be_a(OpenAssets::Protocol::HttpAssetDefinitionLoader)
      end
    end

    context 'invalid scheme' do
      subject{
        OpenAssets::Protocol::AssetDefinitionLoader.new('<http://www.caiselian.com>')
      }
      it do
        expect(subject.load_definition).to be_nil
      end
    end

  end

  describe 'create_pointer_redeem_script' do
    subject {
      OpenAssets::Protocol::AssetDefinitionLoader.create_pointer_redeem_script('https://goo.gl/bmVEuw', 'bWwvzRQ6Lux9rWgeqTe91XwbxvFuxzK56cx')
    }
    it do
      expect(subject.chunks[0]).to eq('u=https://goo.gl/bmVEuw')
      expect(subject.chunks[1]).to eq(Bitcoin::Script::OP_DROP)
      expect(subject.chunks[2]).to eq(Bitcoin::Script::OP_DUP)
      expect(subject.chunks[3]).to eq(Bitcoin::Script::OP_HASH160)
      expect(subject.chunks[4]).to eq('46c2fbfbecc99a63148fa076de58cf29b0bcf0b0'.htb) # bWwvzRQ6Lux9rWgeqTe91XwbxvFuxzK56cx のBitcoinアドレスのhash160
      expect(subject.chunks[5]).to eq(Bitcoin::Script::OP_EQUALVERIFY)
      expect(subject.chunks[6]).to eq(Bitcoin::Script::OP_CHECKSIG)
    end
  end

  describe 'create_pointer_p2sh' do
    subject {
      OpenAssets::Protocol::AssetDefinitionLoader.create_pointer_p2sh('https://goo.gl/bmVEuw', 'bWwvzRQ6Lux9rWgeqTe91XwbxvFuxzK56cx')
    }
    it do
      expect(subject.is_p2sh?).to be true
    end
  end

end