require 'feature_helper'

describe HealthCheck::PqaApi do
  let(:pqa) { HealthCheck::PqaApi.new }


  describe '.time_to_run?' do
    it 'should be true if the timestamp file does not exist' do
      delete_timestamp_file
      expect(HealthCheck::PqaApi.time_to_run?).to be true
    end

    it 'should be true if the timestamp file contains a time more than 15 minutes ago' do
      Timecop.freeze(16.minutes.ago) { HealthCheck::PqaApi.new }
      expect(HealthCheck::PqaApi.time_to_run?).to be true
    end

    it 'should be false if the timestamp file contains a time less than 15 minutes ago' do
      Timecop.freeze(14.minutes.ago) { HealthCheck::PqaApi.new }
      expect(HealthCheck::PqaApi.time_to_run?).to be false
    end
  end

  context '#available?' do
    it 'returns true if the parliamentary questions API is available' do
      expect(pqa).to be_available
    end

    it 'returns false if the parliamentary questions API is not available' do
      allow_any_instance_of(Net::HTTP)
        .to receive(:request)
        .and_raise(Net::ReadTimeout)

      expect(pqa).not_to be_available
    end
  end

  context '#accessible?' do
    let(:resp_403) { double Net::HTTPResponse, code: 403, body: 'unauthorised' }

    it 'returns true if the parliamentary questions API is accessible with our credentials' do
      expect(pqa).to be_accessible
    end

    it 'returns false if the parliamentary questions API is not accessible with our credentials' do
      allow_any_instance_of(Net::HTTP)
        .to receive(:request)
        .and_return(resp_403)

      expect(pqa).not_to be_accessible
    end
  end

  context '#error_messages' do
    it 'returns the exception messages if there is an error accessing the parliamentary questions API' do
      allow_any_instance_of(Net::HTTP)
        .to receive(:request)
        .and_raise(Errno::ECONNREFUSED)

      pqa.available?

      expect(pqa.error_messages).to eq ['PQA API Access Error: Connection refused']
    end

    it 'returns an error an backtrace for errors not specific to a component' do
      allow_any_instance_of(Net::HTTP)
        .to receive(:request)
        .and_raise(StandardError)

      pqa.available?

      expect(pqa.error_messages.first).to match /Error: StandardError\nDetails/
    end
  end
end


def delete_timestamp_file
  if File.exist?(HealthCheck::PqaApi::TIMESTAMP_FILE)
    File.unlink(HealthCheck::PqaApi::TIMESTAMP_FILE)
  end
end
