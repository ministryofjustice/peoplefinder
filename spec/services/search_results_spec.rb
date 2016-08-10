require 'rails_helper'

RSpec.describe SearchResults, type: :service do
  it { is_expected.to respond_to(:set) }
  it { is_expected.to respond_to(:set=) }
  it { is_expected.to respond_to(:contains_exact_match) }
  it { is_expected.to respond_to(:contains_exact_match=) }

  it { should delegate_method(:size).to(:set) }
  it { should delegate_method(:each).to(:set) }

  it 'defaults to empty set and false' do
    expect(subject.set).to be_empty
    expect(subject.contains_exact_match).to eq false
  end
end
