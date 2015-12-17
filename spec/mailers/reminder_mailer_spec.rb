require 'rails_helper'

RSpec.describe ReminderMailer do
  include PermittedDomainHelper

  let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }

  shared_examples 'sets email to and from correctly' do
    it 'sets the sender' do
      expect(mail.from).to include(Rails.configuration.support_email)
    end

    it 'sets the correct recipient' do
      expect(mail.to).to include(person.email)
    end
  end

  shared_examples 'subject contains' do |subject|
    it 'sets the subject' do
      expect(mail.subject).to have_text(subject)
    end
  end

  shared_examples 'body contains' do |text|
    it 'includes body text' do
      %w[plain html].each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(text)
      end
    end
  end

  shared_examples 'includes link to edit person' do
    it 'includes the the person edit url' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(edit_person_url(person))
      end
    end
  end

  describe '.inadequate_profile' do
    let(:mail) { described_class.inadequate_profile(person).deliver_now }

    include_examples 'sets email to and from correctly'

    include_examples 'subject contains', 'Reminder: update your profile today'

    include_examples 'body contains', "profile is 33% complete"

    include_examples 'includes link to edit person'
  end

end
