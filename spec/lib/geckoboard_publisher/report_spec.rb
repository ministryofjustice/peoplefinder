require 'rails_helper'

RSpec.describe GeckoboardPublisher::Report do

  it {is_expected.to respond_to :client }

  describe '#new' do

    let(:client) { double Geckoboard::Client }
    subject { described_class.new }

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

      expect{ subject }.to raise_error Geckoboard::UnauthorizedError
    end
  end

  describe '#dataset_name' do
    xit 'suffixes dataset names with environment name' do
    end
  end

end

# The eventual scheduled job needs to execute stats and publish them

# # profile counts
# GeckoboardPubisher::TotalProfilesReport.publish!
# GeckoboardPubisher::PhotoProfilesReport.publish!
# GeckoboardPubisher::AdditionalInfoProfilesReport.publish!

# # profile modification
# GeckoboardPubisher::AddedProfilesReport.publish!
# GeckoboardPubisher::DeletedProfilesReport.publish!
# GeckoboardPubisher::EditedProfilesReport.publish!

