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

RSpec.shared_examples "multipart emails" do
  it "generates a multipart message (plain text and html)" do
    expect(mail.body.parts.length).to equal 2
    expect(mail.body.parts.collect(&:content_type)).to equal ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
  end
end

RSpec.describe Peoplefinder::UserUpdateMailer do
  let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }



  describe ".new_profile_email" do
    subject(:mail) { described_class.new_profile_email(person).deliver }

    include_examples "observe token_auth feature flag"
  end

  describe ".updated_profile_email" do
    subject(:mail) { described_class.updated_profile_email(person).deliver }

    include_examples "observe token_auth feature flag"
  end

end
