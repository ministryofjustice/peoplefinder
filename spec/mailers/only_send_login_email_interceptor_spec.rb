require 'spec_helper'
require_relative '../../app/mailers/only_send_login_email_interceptor'

RSpec.describe OnlySendLoginEmailInterceptor do

  let(:recipient_string)    { 'staging@example.com' }
  let(:subject_prefix)      { '[STAGING]' }
  let(:login_email_subject) { 'Login email subject text' }
  let(:recipient_interceptor) do
    interceptor = double
    allow(RecipientInterceptor).to receive(:new).and_return interceptor
    interceptor
  end

  before(:each) do
    Mail.defaults { delivery_method :test }
  end

  after(:each) do
    Mail::TestMailer.deliveries.clear
    Mail.defaults { delivery_method :smtp }
  end

  let(:interceptor) do
    described_class.new(recipient_string,
      subject_prefix: subject_prefix,
      login_email_subject: login_email_subject)
  end

  def deliver_mail subject_text: 'some subject'
    Mail.deliver do
      from 'original.from@example.com'
      to 'original.to@example.com'
      subject subject_text
      text_part do
        body 'body'
      end
    end
  end

  describe '#initialize' do
    it 'creates an instance of RecipientInterceptor' do
      expect(RecipientInterceptor).to receive(:new).with(recipient_string, subject_prefix: subject_prefix).and_return recipient_interceptor
      interceptor
    end

    it 'assigns login_email_subject' do
      expect(interceptor.login_email_subject).to eq login_email_subject
    end
  end

  describe 'delivering mail' do
    context 'when non-login email' do
      it 'calls delivering_email on RecipientInterceptor instance' do
        expect(recipient_interceptor).to receive(:delivering_email)

        Mail.register_interceptor interceptor
        deliver_mail subject_text: 'Some subject text'
        Mail.unregister_interceptor interceptor
      end
    end

    context 'with login email' do
      it 'does not call delivering_email on RecipientInterceptor instance' do
        expect(recipient_interceptor).not_to receive(:delivering_email)

        Mail.register_interceptor interceptor
        deliver_mail subject_text: login_email_subject
        Mail.unregister_interceptor interceptor
      end
    end
  end

end
