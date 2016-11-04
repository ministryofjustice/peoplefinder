
# The eventual scheduled job needs to execute stats and publish them

# # profile counts
# GeckoboardPubisher::TotalProfilesReport.publish!
# GeckoboardPubisher::PhotoProfilesReport.publish!
# GeckoboardPubisher::AdditionalInfoProfilesReport.publish!

# # profile modification
# GeckoboardPubisher::AddedProfilesReport.publish!
# GeckoboardPubisher::DeletedProfilesReport.publish!
# GeckoboardPubisher::EditedProfilesReport.publish!

shared_examples 'geckoboard publishable report' do

  let(:client) { double Geckoboard::Client }
  subject { described_class.new }

  it { is_expected.to respond_to :client }
  it { is_expected.to respond_to :id }
  it { is_expected.to respond_to :fields }
  it { is_expected.to respond_to :publish! }

  describe '#new' do
    it 'connects to geckoboard using API key stored in ENV variable' do
      expect(ENV).to receive(:[]).with('GECKOBOARD_API_KEY').and_return 'fake-API-key'
      expect(Geckoboard).to receive(:client).with('fake-API-key').and_return client
      expect(client).to receive(:ping).and_return true
      subject
    end

    it 'returns report instance on success' do
      allow(Geckoboard).to receive(:client).and_return client
      expect(client).to receive(:ping).and_return true
      expect(subject).to be_instance_of described_class
    end

    it 'raises and logs error on failure' do
      allow(Geckoboard).to receive(:client).and_return client
      expect(client).to receive(:ping).and_raise Geckoboard::UnauthorizedError
      logger = double Rails.logger
      expect(Rails).to receive(:logger).and_return logger
      expect(logger).to receive(:warn).with(/.*Geckoboard API key.*/)

      expect { subject }.to raise_error Geckoboard::UnauthorizedError
    end
  end

  describe '#id' do
    before { allow(Rails).to receive(:env).and_return 'staging' }

    it 'is specific to app, environment and report name' do
      expect(subject.id).to eql "peoplefinder-staging.#{described_class.name.demodulize.underscore}"
    end
  end

  describe '#publish' do
    before do
      expect(ENV).to receive(:[]).with('GECKOBOARD_API_KEY').and_return 'fake-API-key'
      expect(Geckoboard).to receive(:client).with('fake-API-key').and_return client
      expect(client).to receive(:ping).and_return true
    end

    it 'creates existing dataset' do
      expect(subject).to receive(:create_dataset!)
      expect(subject).to receive(:replace_dataset!)
      subject.publish!
    end

  end

end
