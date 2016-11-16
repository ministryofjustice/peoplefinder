shared_examples 'geckoboard publishable report' do

  let(:client) { double Geckoboard::Client }
  let(:dataset) { double Geckoboard::Dataset }
  let(:logger) { double Rails.logger }
  subject { described_class.new }

  it { is_expected.to respond_to :client }
  it { is_expected.to respond_to :id }
  it { is_expected.to respond_to :fields }
  it { is_expected.to respond_to :publish! }

  def mock_expectations exit_without_ping = nil
    allow(ENV).to receive(:[]).with('ENV').and_return 'staging'
    expect(ENV).to receive(:[]).with('GECKOBOARD_API_KEY').and_return 'fake-API-key'
    expect(Geckoboard).to receive(:client).with('fake-API-key').and_return client
    return client if exit_without_ping
    expect(client).to receive(:ping).and_return true
    yield client if block_given?
  end

  describe '#new' do
    it 'connects to geckoboard using API key stored in ENV variable' do
      mock_expectations
      subject
    end

    it 'returns report instance on success' do
      mock_expectations
      expect(subject).to be_instance_of described_class
    end

    it 'raises and logs error on failure' do
      client = mock_expectations true
      allow(client).to receive(:ping).and_raise Geckoboard::UnauthorizedError
      expect(Rails).to receive(:logger).and_return logger
      expect(logger).to receive(:warn).with(/.*Geckoboard API key.*/)
      expect { subject }.to raise_error Geckoboard::UnauthorizedError
    end
  end

  describe '#id' do
    before do
      mock_expectations
    end

    it 'is specific to app, environment and report name' do
      expect(subject.id).to eql "peoplefinder-staging.#{described_class.name.demodulize.underscore}"
    end
  end

  describe '#publish!' do
    before do
      mock_expectations
    end

    it 'creates (or finds) geckoboard dataset and replaces its data' do
      expect(subject).to receive(:create_dataset!)
      expect(subject).to receive(:replace_dataset!)
      subject.publish!
    end
  end

  describe '#unpublish!' do
    context 'when dataset exists' do
      it 'deletes the dataset and returns true' do
        mock_expectations do |client|
          expect(client).to receive(:datasets).and_return dataset
          expect(dataset).to receive(:delete).and_return true
          subject.unpublish!
        end
      end
    end

    context 'when dataset does not exist' do
      it 'returns false when the dataset does not exist' do
        mock_expectations do |client|
          expect(client).to receive(:datasets).and_return dataset
          expect(dataset).to receive(:delete).and_raise Geckoboard::UnexpectedStatusError
          expect(subject.unpublish!).to eql false
        end
      end
    end
  end
end

shared_examples 'returns valid items structure' do
  it 'returns a geckoboard compatible format' do
    is_expected.to be_an(Array)
    expect(subject.first).to be_a(Hash)
    expect { subject.to_json }.not_to raise_error
  end

  it 'returns dataset which matches field definitions' do
    fields = described_class.new.fields
    expect(subject.first.keys).to match_array fields.map(&:id)
  end
end
