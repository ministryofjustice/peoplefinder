require 'rails_helper'

RSpec.shared_examples "observe token_auth feature flag" do
  it 'includes the token url with person show path as desired path' do
    expect(mail.body).to have_text(token_url(Token.last, desired_path: person_path(person)))
  end

  context 'token_auth feature disabled' do
    it "includes the person show url without an auth token" do
      without_feature('token_auth') do
        expect(mail.body).to have_text(person_url(person))
      end

    end
  end
end

RSpec.describe UserUpdateMailer do
  include PermittedDomainHelper

  let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }

  describe ".new_profile_email" do
    subject(:mail) { described_class.new_profile_email(person).deliver_now }

    it 'includes the person show url' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(person_url(person))
      end
    end
  end

  describe ".updated_profile_email" do
    subject(:mail) { described_class.updated_profile_email(person).deliver_now }

    it 'includes the person show url' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(person_url(person))
      end
    end
  end

end
