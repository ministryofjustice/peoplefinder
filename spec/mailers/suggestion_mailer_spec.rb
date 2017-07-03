require 'rails_helper'

RSpec.describe SuggestionMailer do
  include PermittedDomainHelper

  let(:suggester) { create(:person, email: 'suggester@digital.justice.gov.uk') }
  let(:person)    { create(:person, email: 'person@digital.justice.gov.uk') }
  let(:admin)     { create(:person, email: 'admin@digital.justice.gov.uk') }

  def expect_mail_body_text(text)
    %w(plain html).each do |part_type|
      expect(get_message_part(mail, part_type)).to have_text(text)
    end
  end

  describe '.person_email' do
    let(:missing_fields_info) { "You're missing some details" }
    let(:suggestion_hash) do
      {
        missing_fields: true,
        missing_fields_info: missing_fields_info,
        incorrect_fields: true,
        incorrect_first_name: true,
        incorrect_last_name: true,
        incorrect_location_of_work: true
      }
    end

    let(:mail) { described_class.person_email(person, suggester, suggestion_hash).deliver_now }

    include_examples 'common mailer template elements'

    it 'is sent from the support address' do
      expect(mail.from).to include(Rails.configuration.support_email)
    end

    it 'is sent to the profile email' do
      expect(mail.to).to include(person.email)
    end

    it 'contains the name of the suggester' do
      expect_mail_body_text(suggester.name)
    end

    describe 'when missing fields suggested' do
      it 'contains contents of missing_fields_info' do
        expect_mail_body_text(missing_fields_info)
      end
    end

    describe 'when incorrect fields suggested' do
      it 'contains list of fields in incorrect_fields_info' do
        expect_mail_body_text('First name')
        expect_mail_body_text('Last name')
        expect_mail_body_text('Location of work')
      end
    end
  end

  describe '.team_admin_email' do
    let(:inappropriate_content_info) { 'A bit saucy' }
    let(:person_left_info) { 'Person left last year' }
    let(:suggestion_hash) do
      {
        duplicate_profile: true,
        inappropriate_content: true,
        inappropriate_content_info: inappropriate_content_info,
        person_left: true,
        person_left_info: person_left_info
      }
    end

    let(:mail) do
      described_class.team_admin_email(
        person,
        suggester,
        suggestion_hash,
        admin
      ).deliver_now
    end

    include_examples 'common mailer template elements'

    it 'is sent from the support address' do
      expect(mail.from).to include(Rails.configuration.support_email)
    end

    it 'is sent to the provided team admin' do
      expect(mail.to).to include(admin.email)
    end

    it 'contains the first name of the team admin' do
      expect_mail_body_text(admin.given_name)
    end

    it 'contains the name of the suggester' do
      expect_mail_body_text(suggester.name)
    end

    it 'contains the name of the person whose profile it concerns' do
      expect_mail_body_text(person.name)
    end

    it 'contains a link to the profile it concerns' do
      expect_mail_body_text(person_url(person))
    end

    describe 'when duplicate profile suggested' do
      it 'contains the text "duplicate profile"' do
        expect_mail_body_text('duplicate profile')
      end
    end

    describe 'when inappropriate content suggested' do
      it 'contains the text "inappropriate content"' do
        expect_mail_body_text('inappropriate content')
      end

      it 'contains inappropriate content info' do
        expect_mail_body_text(inappropriate_content_info)
      end
    end

    describe 'when suggested that person left' do
      it 'contains the text "person left"' do
        expect_mail_body_text('person left')
      end

      it 'contains person left info' do
        expect_mail_body_text(person_left_info)
      end
    end
  end
end
