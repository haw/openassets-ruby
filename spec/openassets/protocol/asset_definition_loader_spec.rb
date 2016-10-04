require 'spec_helper'

describe OpenAssets::Protocol::AssetDefinitionLoader do

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
      OpenAssets::Protocol::AssetDefinitionLoader.create_pointer_redeem_script('https://goo.gl/bmVEuw')
    }
    it do
      expect(subject.chunks[0]).to eq('u=https://goo.gl/bmVEuw')
    end
  end

  describe 'create_pointer_p2sh' do
    subject {
      OpenAssets::Protocol::AssetDefinitionLoader.create_pointer_p2sh('https://goo.gl/bmVEuw')
    }
    it do
      expect(subject.is_p2sh?).to be true
    end
  end

end