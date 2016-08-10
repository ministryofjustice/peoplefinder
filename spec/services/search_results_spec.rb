require 'rails_helper'

RSpec.describe SearchResults, type: :service do

  it { is_expected.to respond_to(:set) }
  it { is_expected.to respond_to(:set=) }
  it { is_expected.to respond_to(:contains_exact_match) }
  it { is_expected.to respond_to(:contains_exact_match=) }
  it { is_expected.to respond_to(:clear) }

  it { should delegate_method(:size).to(:set) }
  it { should delegate_method(:each).to(:set) }

  it 'defaults to empty set and false' do
    expect(subject.set).to be_empty
    expect(subject.contains_exact_match).to eq false
  end

  describe '#clear' do

    subject { described_class.new([1, 2], false) }

    it 'returns self' do
      expect(subject.clear).to be subject
    end

    it 'clears state' do
      expect(subject.set).to_not be_empty
      subject.clear
      expect(subject.set).to be_empty
      expect(subject.contains_exact_match).to eq false
    end
  end

end
