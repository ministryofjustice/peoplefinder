require 'rails_helper'
require 'secure'

describe Secure do

  it 'complains when comparing empty or different sized passes' do
    [nil, ""].each do |empty|
      expect(described_class.compare(empty, "something")).to be_falsey
      expect(described_class.compare("something", empty)).to be_falsey
      expect(described_class.compare(empty, empty)).to be_falsey
    end
    expect(described_class.compare("size_1", "size_four")).to be_falsey
  end

  it 'passes when things match' do
    expect(described_class.compare("some token", "some token")).to be_truthy
  end
end
