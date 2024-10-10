require "rails_helper"

RSpec.describe SearchResults, type: :service do
  it { is_expected.to respond_to(:set) }
  it { is_expected.to respond_to(:set=) }
  it { is_expected.to respond_to(:contains_exact_match) }
  it { is_expected.to respond_to(:contains_exact_match=) }

  it { is_expected.to delegate_method(:size).to(:set) }
  it { is_expected.to delegate_method(:each).to(:set) }
  it { is_expected.to delegate_method(:present?).to(:set) }

  it "defaults to empty set and false" do
    expect(described_class.new.set).to be_empty
    expect(described_class.new.contains_exact_match).to be false
  end
end
