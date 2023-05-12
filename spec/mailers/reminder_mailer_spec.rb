require 'rails_helper'

RSpec.describe ReminderMailer do
  include PermittedDomainHelper

  let(:person) { create(:person, given_name: 'John', surname: 'Coe', email: 'test.user@digital.justice.gov.uk') }

  let!(:group)  do
    person.reload
    team = create(:group)
    team.people << person
    person.memberships.first.update(leader: true)
    team
  end

  shared_examples 'sets email recipient correctly' do
    it 'sets the correct recipient' do
      expect(mail.to).to include(person.email)
    end
  end

  shared_examples 'includes name' do |name|
    it 'includes data' do
      expect(mail.govuk_notify_personalisation[:name]).to eq name
    end
  end

  shared_examples 'includes link to edit group' do
    it 'includes the person edit url' do
      edit_url = edit_group_url(group)
      expect(mail.govuk_notify_personalisation[:edit_group_url]).to eq edit_url
    end
  end

  shared_examples 'includes link to token login' do
    it 'includes the token login url' do
      expect(mail.govuk_notify_personalisation[:token_url]).to have_text('http://www.example.com/tokens/')
    end
  end

  describe '.never_logged_in' do
    let(:mail) { described_class.never_logged_in(person).deliver_now }

    include_examples 'sets email recipient correctly'
    include_examples 'includes name', 'John'
    include_examples 'includes link to token login'

    it 'sets the template' do
      expect(mail.govuk_notify_template).to eq 'afea2e90-d721-4cbe-be97-a89dd6973af6'
    end

  end

  describe '.team_description_missing' do
    let(:mail) { described_class.team_description_missing(person, group).deliver_now }

    include_examples 'sets email recipient correctly'
    include_examples 'includes name', 'John'
    include_examples 'includes link to edit group'

    it 'sets the template' do
      expect(mail.govuk_notify_template).to eq 'eecbbb2a-b8c9-4783-b70f-c48b2bacaed8'
    end

  end

  describe '.person_profile_update' do
    let(:mail) { described_class.person_profile_update(person).deliver_now }

    include_examples 'sets email recipient correctly'
    include_examples 'includes link to token login'

    it 'includes profile details' do
      data = mail.govuk_notify_personalisation
      expect(data[:given_name]).to eq 'John'
      expect(data[:person_name]).to eq 'John Coe'
      expect(data[:location]).to eq '-'
      expect(data[:primary_phone_number]).to eq '-'
      expect(data[:current_projects]).to eq '-'
    end

    it 'sets the template' do
      expect(mail.govuk_notify_template).to eq 'ad85435b-3c8f-4092-865a-4320ff5745f1'
    end
  end
end
