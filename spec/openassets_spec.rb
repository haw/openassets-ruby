require 'spec_helper'

describe OpenAssets do

  it 'has a version number' do
    expect(OpenAssets::VERSION).not_to be nil
  end

  it 'is testnet?' do
    expect(OpenAssets.is_testnet?).to be true
    OpenAssets.config.update({network: 'mainnet'})
    expect(OpenAssets.is_testnet?).to be false
  end
end
