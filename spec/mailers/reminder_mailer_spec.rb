require 'rails_helper'

RSpec.describe ReminderMailer do
  describe '.inadequate_profile' do
    let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }
    let(:mail) { described_class.inadequate_profile(person).deliver_now }

    it 'sets the sender' do
      expect(mail.from).to include(Rails.configuration.support_email)
    end

    it 'sets the correct recipient' do
      expect(mail.to).to include(person.email)
    end

    it 'sets the subject' do
      expect(mail.subject).to have_text('Reminder: update your profile today')
    end

    it 'describes the profile completion score' do
      %w[plain html].each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text("profile is #{ person.completion_score }% complete")
      end
    end

    it 'includes the the person edit url' do
      %w[plain html].each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(edit_person_url(person))
      end
    end
  end
end
