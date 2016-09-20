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

end