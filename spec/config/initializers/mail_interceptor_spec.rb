require 'rails_helper'

RSpec.context 'on initialization', type: :initializer do

  context 'when INTERCEPTED_EMAIL_RECIPIENT set' do
    before do
      ENV['INTERCEPTED_EMAIL_RECIPIENT'] = 'test@example.com'
      require_relative '../../../config/initializers/mail_interceptor'
    end

    after do
      interceptor = Mail.class_variable_get(:@@delivery_interceptors).last
      Mail.unregister_interceptor interceptor
      ENV['INTERCEPTED_EMAIL_RECIPIENT'] = nil
    end

    it 'sets Mail delivery_interceptors correctly' do
      interceptor = Mail.class_variable_get(:@@delivery_interceptors).last
      expect(interceptor).to be_a(OnlySendLoginEmailInterceptor)
      expect(interceptor.login_email_subject).to eq 'Access request to MOJ People Finder'
    end
  end

  context 'when INTERCEPTED_EMAIL_RECIPIENT not set' do
    it 'leaves Mail delivery_interceptor unchanged' do
      interceptor = Mail.class_variable_get(:@@delivery_interceptors).last
      expect(interceptor).not_to be_a(OnlySendLoginEmailInterceptor)
    end
  end
end
