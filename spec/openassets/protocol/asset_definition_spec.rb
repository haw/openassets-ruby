require 'spec_helper'

describe OpenAssets::Protocol::AssetDefinition do

  json = <<"EOF"
  {
    "asset_ids": [
      "AGHhobo7pVQN5fZWqv3rhdc324ryT7qVTB",
      "AWo3R89p5REmoSyMWB8AeUmud8456bRxZL",
      "AJk2Gx5V67S2wNuwTK5hef3TpHunfbjcmX"
    ],
    "contract_url": "http://techmedia-think.hatenablog.com/",
    "name_short": "HAWSCoin",
    "name": "MHAWS Coin",
    "issuer": "Shigeyuki Azuchi",
    "description": "The OpenAsset test description.",
    "description_mime": "text/x-markdown; charset=UTF-8",
    "type": "Currency",
    "divisibility": 1,
    "link_to_website": false,
    "version": "1.0"
  }
EOF

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
    definition = OpenAssets::Protocol::AssetDefinition.parse_url('https://cpr.sm/uNhUNQxM7-')
    expect(definition.asset_ids.length).to eq(1)
    expect(definition.asset_ids[0]).to eq('AboLrT5sHA1epmW2CL7UPqQ1AwwhomK8Si')
    expect(definition.name_short).to eq('oat')
    expect(definition.name).to eq('openassets-test')
    expect(definition.contract_url).to eq('https://www.coinprism.info/asset/AboLrT5sHA1epmW2CL7UPqQ1AwwhomK8Si')
    expect(definition.issuer).to eq('Shigeyuki Azuchi')
    expect(definition.description).to eq('for openassets-ruby test.')
    expect(definition.description_mime).to eq('text/x-markdown; charset=UTF-8')
    expect(definition.type).to eq('Currency')
    expect(definition.divisibility).to eq(0)
    expect(definition.link_to_website).to be false
    expect(definition.icon_url).to be_nil
    expect(definition.image_url).to be_nil
    expect(definition.version).to eq('1.0')
  end

  it 'include asset id' do
    definition = OpenAssets::Protocol::AssetDefinition.parse_json(json)
    expect(definition.include_asset_id?('AboLrT5sHA1epmW2CL7UPqQ1AwwhomK8Si')).to be false
    expect(definition.include_asset_id?('AJk2Gx5V67S2wNuwTK5hef3TpHunfbjcmX')).to be true

  end

end