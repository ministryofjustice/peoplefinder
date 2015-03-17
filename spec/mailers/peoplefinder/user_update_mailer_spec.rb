require 'rails_helper'

RSpec.configure do |c|
  c.include Peoplefinder::Engine.routes.url_helpers
end


RSpec.shared_examples "observe token_auth feature flag" do
  it 'includes the token url with person show path as desired path' do
    expect(mail.body).to have_text(token_url(Peoplefinder::Token.last, desired_path: person_path(person)))
  end

  context 'token_auth feature disabled' do
    it "includes the person show url without an auth token" do
      without_feature('token_auth') do
        expect(mail.body).to have_text(person_url(person))
      end
    end
  end
end


RSpec.describe Peoplefinder::UserUpdateMailer do
  let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }



  describe ".new_profile_email" do
    subject(:mail) { described_class.new_profile_email(person).deliver_now }

    it 'includes the person show url' do
      expect(mail.body).to have_text(person_url(person))
    end
  end

  describe ".updated_profile_email" do
    subject(:mail) { described_class.updated_profile_email(person).deliver_now }

    it 'includes the person show url' do
      expect(mail.body).to have_text(person_url(person))
    end
  end

end
