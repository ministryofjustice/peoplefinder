require "rails_helper"

RSpec.describe PgSearchResults do
  it { is_expected.to respond_to(:set) }
  it { is_expected.to respond_to(:set=) }
  it { is_expected.to respond_to(:contains_exact_match) }
  it { is_expected.to respond_to(:contains_exact_match=) }
  it { is_expected.to respond_to(:hit_builder) }
  it { is_expected.to respond_to(:hit_builder=) }

  it { is_expected.to delegate_method(:size).to(:set) }
  it { is_expected.to delegate_method(:each).to(:set) }
  it { is_expected.to delegate_method(:present?).to(:set) }
  it { is_expected.to delegate_method(:empty?).to(:set) }

  it "defaults to empty set and false" do
    expect(described_class.new.set).to be_empty
    expect(described_class.new.contains_exact_match).to be false
  end

  describe "#each_with_hit" do
    let(:person) { instance_double(Person) }

    context "when hit_builder is set" do
      it "yields each person with the result of calling hit_builder" do
        hit = instance_double(PersonPgSearch::Hit)
        results = described_class.new(set: [person])
        results.hit_builder = ->(_p) { hit }

        yielded = []
        results.each_with_hit { |p, h| yielded << [p, h] }

        expect(yielded).to eq [[person, hit]]
      end
    end

    context "when hit_builder is nil" do
      it "yields each person with nil as the hit" do
        results = described_class.new(set: [person])

        yielded = []
        results.each_with_hit { |p, h| yielded << [p, h] }

        expect(yielded).to eq [[person, nil]]
      end
    end

    context "without a block" do
      it "returns an enumerator" do
        results = described_class.new(set: [person])
        expect(results.each_with_hit).to be_an(Enumerator)
      end
    end
  end
end
