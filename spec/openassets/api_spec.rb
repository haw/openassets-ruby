require 'spec_helper'

describe OpenAssets::Api do

  BTC_UNSPENT = [
    {'txid'=>'8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8220', 'vout'=>0, 'address'=>'139868qtP1rhcRxGPwiuvkj4tEWbJ8FdT3', 'account'=>'account1', 'scriptPubKey'=>'76a91417797f19075a56e7d4fc23f2ea5c17020fd3b93d88ac', 'amount'=>0.001, 'confirmations'=>18, 'spendable'=>true} ,
    {'txid'=>'8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8220', 'vout'=>1, 'address'=>'1Mi8fwGq1fDkMmLHTZbGgNAESGMh1377sS', 'scriptPubKey'=>'76a914e329f94a77fc436fceebdff649ca8741172fb07988ac', 'amount'=>0.00884486, 'confirmations'=>18, 'spendable'=>true}
  ]

  OA_UNSPENT = [
    {'txid' =>  '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8220', 'asset_quantity' =>  '0','script' => '76a91417797f19075a56e7d4fc23f2ea5c17020fd3b93d88ac',
      'amount' =>  '0.00100000','address' => '139868qtP1rhcRxGPwiuvkj4tEWbJ8FdT3','oa_address' => 'akD71LJfDrVkPUg7dSZq6acdeDqgmHjrc2Q',
      'asset_id' => nil,'vout' => 0,'confirmations' => 8
    },
    {
      'txid' => '8a7e2adf117199f93c8515266497d2b9954f3f3dea0f043e06c19ad2b21b8220','asset_quantity' => '0','script' => '76a914e329f94a77fc436fceebdff649ca8741172fb07988ac',
      'amount' => '0.00884486','address' => '1Mi8fwGq1fDkMmLHTZbGgNAESGMh1377sS','oa_address' => 'akXg1v76AV97SE1VeWBhTLE4omsXrz2dFcL',
      'asset_id' => nil,'vout' => 1,'confirmations' => 8
    }
  ]

  it 'load configuration' do
    api = OpenAssets::Api.new
    expect(api.is_testnet?).to be false
    expect(api.config[:rpc][:host]).to eq('localhost')
    expect(api.config[:rpc][:port]).to eq(8332)
    api = OpenAssets::Api.new(JSON.parse(File.read("#{File.dirname(__FILE__)}/../test-config.json"), {:symbolize_names => true}))
    expect(api.is_testnet?).to be true
  end

  it 'list_unspent' do
    btc_provider_mock = double('BitcoinCoreProvider Mock')
    api = OpenAssets::Api.new
    allow(btc_provider_mock).to receive(:list_unspent).and_return(BTC_UNSPENT)
    allow(api).to receive(:provider).and_return(btc_provider_mock)
    list = api.list_unspent
    expect(list[0][:txid]).to eq(OA_UNSPENT[0][:txid])
    expect(list[0][:asset_quantity]).to eq(OA_UNSPENT[0][:asset_quantity])
    expect(list[0][:asset_id]).to eq(OA_UNSPENT[0][:asset_id])
    expect(list[0][:script]).to eq(OA_UNSPENT[0][:script])
    expect(list[0][:amount]).to eq(OA_UNSPENT[0][:amount])
    expect(list[0][:confirmations]).to eq(OA_UNSPENT[0][:confirmations])
    expect(list[0][:oa_address]).to eq(OA_UNSPENT[0][:oa_address])
    expect(list[0][:address]).to eq(OA_UNSPENT[0][:address])
    expect(list[1][:txid]).to eq(OA_UNSPENT[1][:txid])
    expect(list[1][:asset_quantity]).to eq(OA_UNSPENT[1][:asset_quantity])
    expect(list[1][:asset_id]).to eq(OA_UNSPENT[1][:asset_id])
    expect(list[1][:script]).to eq(OA_UNSPENT[1][:script])
    expect(list[1][:amount]).to eq(OA_UNSPENT[1][:amount])
    expect(list[1][:confirmations]).to eq(OA_UNSPENT[1][:confirmations])
    expect(list[1][:oa_address]).to eq(OA_UNSPENT[1][:oa_address])
    expect(list[1][:address]).to eq(OA_UNSPENT[1][:address])
  end

end