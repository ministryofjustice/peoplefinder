require 'rails_helper'

RSpec.describe ReminderMailer do

  describe '.inadequate_profile' do
    let(:person) { create(:person, email: 'test@example.com') }
    let(:mail) { described_class.inadequate_profile(person).deliver }

    it 'sets the sender' do
      expect(mail.from).to include('peoplefinder@digital.justice.gov.uk')
    end

    it 'sets the correct recipient' do
      expect(mail.to).to include(person.email)
    end

    it 'sets the subject' do
      expect(mail.subject).to have_text('Update your Peoplefinder profile')
    end

    it 'has a greeting' do
      expect(mail.body).to have_text("Hello #{ person }")
    end

    it 'describes the profile completion score' do
      expect(mail.body).to have_text("profile is only #{ person.completion_score }% complete")
    end

    it 'includes the page url' do
      expect(mail.body).to have_text("/people/#{ person.to_param }/edit")
    end
  end
end
