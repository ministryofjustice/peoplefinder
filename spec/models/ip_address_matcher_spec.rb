require 'spec_helper'
require 'ip_address_matcher'

RSpec.describe IpAddressMatcher do
  it 'matches a single IP address' do
    matcher = described_class.new('12.34.56.78')
    expect(matcher.===('12.34.56.78')).to be_truthy
    expect(matcher.===('11.22.33.44')).to be_falsy
  end

  it 'matches several IP addresses' do
    matcher = described_class.new('12.34.56.78;127.0.0.1;8.8.8.8')
    expect(matcher.===('12.34.56.78')).to be_truthy
    expect(matcher.===('127.0.0.1')).to be_truthy
    expect(matcher.===('8.8.8.8')).to be_truthy
    expect(matcher.===('11.22.33.44')).to be_falsy
  end

  it 'matches CIDR ranges' do
    matcher = described_class.new('12.34.0.0/16;127.0.0.0/24')
    expect(matcher.===('12.34.56.78')).to be_truthy
    expect(matcher.===('127.0.0.1')).to be_truthy
    expect(matcher.===('12.33.44.44')).to be_falsy
  end
end
