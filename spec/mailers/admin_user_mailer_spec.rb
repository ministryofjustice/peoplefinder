require 'rails_helper'

describe AdminUserMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include Rails.application.routes.url_helpers

  describe 'password reset email' do
    let(:user) { create(:admin_user, name: 'Bob') }
    let(:password_reset) { double(:password_reset, user: user) }
    let(:email) { described_class.password_reset(password_reset) }

    it 'is sent to the given user' do
      expect(email.to.first).to eql user.email
    end

    it 'has the subject "Password reset"' do
      expect(email.subject).to eql 'Password reset'
    end

    it 'has instructions for resetting your password' do
      expect(email).to have_body_text 'Please click on the link below to reset your password:'
    end
  end
end
