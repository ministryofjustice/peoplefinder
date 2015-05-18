require 'rails_helper'

describe HealthCheck::SendGrid do
  subject { described_class.new }
  let(:smtp) { double Net::SMTP }

  context '#available?' do
    it 'returns true if the component is available' do
      allow(Net::SMTP).to receive(:start).and_yield(smtp)
      allow(smtp).to receive(:helo)

      expect(subject).to be_available
    end

    it 'returns false if the component is not available' do
      allow(Net::SMTP).to receive(:start).and_yield(smtp)
      allow(smtp).to receive(:helo).and_raise(Net::SMTPServerBusy)

      expect(subject).not_to be_available
    end
  end

  context '#accessible?' do
    before(:each) do
      allow(Net::SMTP).to receive(:start).and_yield(smtp)
    end

    it 'returns true if the component is accessible with our credentials' do
      expect(smtp).to receive(:authenticate).and_return('OK')

      expect(subject).to be_accessible
    end

    it 'returns false if the component is not accessible with our credentials' do
      expect(smtp).to receive(:authenticate).
        and_raise(Net::SMTPAuthenticationError)

      expect(subject).not_to be_accessible
    end
  end

  context '#errors' do
    it 'returns the exception messages if there is an error accessing the component' do
      allow(Net::SMTP).to receive(:start).and_yield(smtp)
      allow(smtp).to receive(:authenticate).
        and_raise(Net::SMTPAuthenticationError)
      subject.accessible?

      expect(subject.errors).to eq(
        ['SendGrid Authentication Error: Net::SMTPAuthenticationError']
      )
    end

    it 'returns an error an backtrace for errors not specific to a component' do
      allow(Net::SMTP).to receive(:start).and_raise(StandardError)
      subject.accessible?

      expect(subject.errors.first).
        to match(/Error: StandardError\nDetails/)
    end
  end
end
