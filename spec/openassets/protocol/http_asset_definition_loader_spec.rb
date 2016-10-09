require 'spec_helper'

describe OpenAssets::Protocol::HttpAssetDefinitionLoader do

  describe 'load' do

    context 'correct content' do
      subject{
        OpenAssets::Protocol::HttpAssetDefinitionLoader.new('http://goo.gl/fS4mEj').load
      }
      it do
        expect(subject.asset_ids.length).to eq(4)
        expect(subject.asset_ids[0]).to eq('AGHhobo7pVQN5fZWqv3rhdc324ryT7qVTB')
        expect(subject.name_short).to eq('HAWSCoin')
        expect(subject.name).to eq('MHAWS Coin')
        expect(subject.contract_url).to eq('http://techmedia-think.hatenablog.com/')
        expect(subject.issuer).to eq('Shigeyuki Azuchi')
        expect(subject.description).to eq('カラーコインの実験用通貨です。')
        expect(subject.description_mime).to eq('text/x-markdown; charset=UTF-8')
        expect(subject.type).to eq('Currency')
        expect(subject.divisibility).to eq(1)
        expect(subject.link_to_website).to be false
        expect(subject.icon_url).to be_nil
        expect(subject.image_url).to be_nil
        expect(subject.version).to eq('1.0')
      end
    end

    context '404' do
      subject{
        OpenAssets::Protocol::HttpAssetDefinitionLoader.new('https://github.com/haw-itn/openassets-ruby/hoge').load
      }
      it do
        expect(subject).to be_nil
      end
    end
  end

end