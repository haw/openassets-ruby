require 'spec_helper'
describe OpenAssets::Provider::BitcoinCoreProvider do

  it 'undefined api call' do
    provider = OpenAssets::Provider::BitcoinCoreProvider.new({})
    expect(provider).to receive(:request).with('getinfo')
    provider.getinfo
  end

end