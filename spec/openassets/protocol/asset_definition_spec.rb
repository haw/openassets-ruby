require 'spec_helper'

describe OpenAssets::Protocol::AssetDefinition do

  json = '{"asset_ids":["AGHhobo7pVQN5fZWqv3rhdc324ryT7qVTB","AWo3R89p5REmoSyMWB8AeUmud8456bRxZL","AJk2Gx5V67S2wNuwTK5hef3TpHunfbjcmX"],"version":"1.0","divisibility":1,"name_short":"HAWSCoin","name":"MHAWS Coin","contract_url":"http://techmedia-think.hatenablog.com/","issuer":"Shigeyuki Azuchi","description":"The OpenAsset test description.","description_mime":"text/x-markdown; charset=UTF-8","type":"Currency","link_to_website":false}'

  it 'parse_json' do
    definition = OpenAssets::Protocol::AssetDefinition.parse_json(json)
    expect(definition.asset_ids.length).to eq(3)
    expect(definition.asset_ids[0]).to eq('AGHhobo7pVQN5fZWqv3rhdc324ryT7qVTB')
    expect(definition.name_short).to eq('HAWSCoin')
    expect(definition.name).to eq('MHAWS Coin')
    expect(definition.contract_url).to eq('http://techmedia-think.hatenablog.com/')
    expect(definition.issuer).to eq('Shigeyuki Azuchi')
    expect(definition.description).to eq('The OpenAsset test description.')
    expect(definition.description_mime).to eq('text/x-markdown; charset=UTF-8')
    expect(definition.type).to eq('Currency')
    expect(definition.divisibility).to eq(1)
    expect(definition.link_to_website).to be false
    expect(definition.icon_url).to be_nil
    expect(definition.image_url).to be_nil
    expect(definition.version).to eq('1.0')
  end

  it 'parse url' do
    definition = OpenAssets::Protocol::AssetDefinition.parse_url('http://goo.gl/fS4mEj')
    expect(definition.asset_ids.length).to eq(3)
    expect(definition.asset_ids[0]).to eq('AGHhobo7pVQN5fZWqv3rhdc324ryT7qVTB')
    expect(definition.name_short).to eq('HAWSCoin')
    expect(definition.name).to eq('MHAWS Coin')
    expect(definition.contract_url).to eq('http://techmedia-think.hatenablog.com/')
    expect(definition.issuer).to eq('Shigeyuki Azuchi')
    expect(definition.description).to eq('カラーコインの実験用通貨です。')
    expect(definition.description_mime).to eq('text/x-markdown; charset=UTF-8')
    expect(definition.type).to eq('Currency')
    expect(definition.divisibility).to eq(1)
    expect(definition.link_to_website).to be false
    expect(definition.icon_url).to be_nil
    expect(definition.image_url).to be_nil
    expect(definition.version).to eq('1.0')
  end

  it '404 url' do
    expect(OpenAssets::Protocol::AssetDefinition.parse_url('https://github.com/haw-itn/openassets-ruby/hoge')).to be nil
  end

  it 'include asset id' do
    definition = OpenAssets::Protocol::AssetDefinition.parse_json(json)
    expect(definition.include_asset_id?('AboLrT5sHA1epmW2CL7UPqQ1AwwhomK8Si')).to be false
    expect(definition.include_asset_id?('AJk2Gx5V67S2wNuwTK5hef3TpHunfbjcmX')).to be true
  end

  it 'to_json' do
    definition = OpenAssets::Protocol::AssetDefinition.new
    definition.asset_ids[0] = 'AGHhobo7pVQN5fZWqv3rhdc324ryT7qVTB'
    definition.asset_ids[1] = 'AWo3R89p5REmoSyMWB8AeUmud8456bRxZL'
    definition.asset_ids[2] = 'AJk2Gx5V67S2wNuwTK5hef3TpHunfbjcmX'
    definition.name_short = 'HAWSCoin'
    definition.name = 'MHAWS Coin'
    definition.contract_url = 'http://techmedia-think.hatenablog.com/'
    definition.issuer = 'Shigeyuki Azuchi'
    definition.description = 'The OpenAsset test description.'
    definition.description_mime = 'text/x-markdown; charset=UTF-8'
    definition.type = 'Currency'
    definition.divisibility = 1
    definition.link_to_website = false
    definition.version = '1.0'

    expect(definition.to_json).to eq(json)
  end

end