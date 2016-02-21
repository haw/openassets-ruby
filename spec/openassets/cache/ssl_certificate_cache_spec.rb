require 'spec_helper'
require 'timecop'
describe OpenAssets::Cache::SSLCertificateCache do

  before :all do
    Timecop.freeze(Time.new(2016,2,21))
  end

  after :all do
    Timecop.return
  end

  subject{
    OpenAssets::Cache::SSLCertificateCache.new
  }

  it 'check expire date' do
    url = 'https://s3-ap-northeast-1.amazonaws.com/colorcoin-metadata/metadata.json'

    subject.put(url, 'Amazon.com Inc.', Time.parse('2016-02-20'))
    expect(subject.get(url)).to be nil

    subject.put(url, 'Amazon.com Inc.', Time.parse('2016-02-25'))
    expect(subject.get(url)).to eq('Amazon.com Inc.')
  end

end