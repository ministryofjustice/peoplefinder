require 'rails_helper'

RSpec.describe ReminderMailer do

  describe '.inadequate_profile' do
    let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }
    let(:mail) { described_class.inadequate_profile(person).deliver }

    it 'sets the sender' do
      expect(mail.from).to include('people-finder@digital.justice.gov.uk')
    end

    it 'sets the correct recipient' do
      expect(mail.to).to include(person.email)
    end

    it 'sets the subject' do
      expect(mail.subject).to have_text('Reminder: update your profile today')
    end

    it 'describes the profile completion score' do
      expect(mail.body).to have_text("profile is #{ person.completion_score }% complete")
    end

    it 'includes the token url with desired path' do
      expect(mail.body).to have_text(token_url(Token.last, desired_path: "/people/#{ person.to_param }/edit"))
    end
  end
end
