shared_examples "geckoboard publishable report" do
  subject { described_class.new }

  let(:client) { instance_double Geckoboard::Client }
  let(:datasets_client) { instance_double Geckoboard::DatasetsClient }
  let(:dataset) { double Geckoboard::Dataset } # rubocop:disable RSpec/VerifiedDoubles
  let(:logger) { double Rails.logger } # rubocop:disable RSpec/VerifiedDoubles

  it { expect(described_class).to have_constant name: :ITEMS_CHUNK_SIZE, value: 500 }
  it { expect(described_class).to have_constant name: :MAX_STRING_LENGTH, value: 100 }
  it { is_expected.to respond_to :client }
  it { is_expected.to respond_to :id }
  it { is_expected.to respond_to :fields }
  it { is_expected.to respond_to :publish! }
  it { is_expected.to respond_to :force? }
  it { is_expected.to respond_to :published? }

  def mock_expectations(exit_without_ping = nil)
    allow(ENV).to receive(:[]).with("ENV").and_return "staging"
    allow(ENV).to receive(:[]).with("GECKOBOARD_API_KEY").and_return "fake-API-key"
    allow(Geckoboard).to receive(:client).with("fake-API-key").and_return client
    return client if exit_without_ping

    allow(client).to receive(:ping).and_return true
    yield client if block_given?
  end
  describe "#new" do
    it "connects to geckoboard using API key stored in ENV variable" do
      mock_expectations
      subject
    end

    it "returns report instance on success" do
      mock_expectations
      expect(subject).to be_instance_of described_class
    end

    it "raises and logs error on failure" do
      client = mock_expectations true
      allow(client).to receive(:ping).and_raise Geckoboard::UnauthorizedError
      allow(Rails).to receive(:logger).and_return logger
      expect(logger).to receive(:warn).with(/.*Geckoboard API key.*/)
      expect { subject }.to raise_error Geckoboard::UnauthorizedError
    end
  end

  describe "#id" do
    before do
      mock_expectations
    end

    it "is specific to app, environment and report name" do
      expect(subject.id).to eql "peoplefinder-staging.#{described_class.name.demodulize.underscore}"
    end
  end

  describe "#publish!" do
    it "creates (or finds) geckoboard dataset and replaces its data" do
      mock_expectations
      allow(subject).to receive(:create_dataset!) # rubocop:disable RSpec/SubjectStub
      allow(subject).to receive(:replace_dataset!).and_return true # rubocop:disable RSpec/SubjectStub
      expect(subject.publish!).to be true
    end

    context "when handling conflict errors" do
      before do
        mock_expectations do |client|
          allow(client).to receive(:datasets).and_return datasets_client
          allow(datasets_client).to receive(:find_or_create).with(any_args).and_raise Geckoboard::ConflictError
        end
      end

      it "by overwriting existing dataset when force specified" do
        expect(subject).to receive(:overwrite!) # rubocop:disable RSpec/SubjectStub
        subject.publish! force: true
      end

      it "by raising errors when force not specified" do
        expect(subject).not_to receive(:overwrite!) # rubocop:disable RSpec/SubjectStub
        expect { subject.publish! }.to raise_error Geckoboard::ConflictError
      end
    end
  end

  describe "#unpublish!" do
    context "when dataset exists" do
      it "deletes the dataset and returns true" do
        mock_expectations do |client|
          allow(client).to receive(:datasets).and_return dataset
          allow(dataset).to receive(:delete).and_return true
          expect(subject.unpublish!).to be true
        end
      end
    end

    context "when dataset does not exist" do
      it "returns false" do
        mock_expectations do |client|
          allow(client).to receive(:datasets).and_return dataset
          allow(dataset).to receive(:delete).and_raise Geckoboard::UnexpectedStatusError
          expect(subject.unpublish!).to be false
        end
      end
    end
  end
end

shared_examples "returns valid items structure" do
  it "returns a geckoboard compatible format" do
    expect(subject).to be_an(Array)
    expect(subject.first).to be_a(Hash)
    expect { subject.to_json }.not_to raise_error
  end

  it "returns dataset which matches field definitions" do
    fields = described_class.new.fields
    expect(subject.first.keys).to match_array fields.map(&:id)
  end
end
