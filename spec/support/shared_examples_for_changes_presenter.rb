shared_examples_for "a changes_presenter" do
  it { is_expected.to be_a(described_class) }
  it { is_expected.to respond_to :changes }
  it { is_expected.to respond_to :raw }
  it { is_expected.to respond_to :[] }
  it { is_expected.to respond_to :each }
  it { is_expected.to respond_to :each_pair }
end

shared_examples_for '#changes on changes_presenter' do
  it { is_expected.to be_a Hash }
  it { is_expected.to respond_to :[] }
  it { is_expected.to respond_to :each }
  it { is_expected.to respond_to :each_pair }
end

shared_examples_for 'serializability' do
  it { is_expected.to be_json }

  describe '.deserialize' do
    it 'is deserializable' do
      expect { described_class.deserialize(subject) }.to_not raise_error
    end

    it "deserializes to instance of #{described_class}" do
      expect(described_class.deserialize(subject)).to be_instance_of described_class
    end
  end
end
