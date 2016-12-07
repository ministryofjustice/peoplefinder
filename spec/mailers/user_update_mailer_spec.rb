require 'rails_helper'

shared_examples "observe token_auth feature flag" do
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

describe UserUpdateMailer do
  include PermittedDomainHelper

  shared_examples "common #{described_class} mail elements" do
    it 'includes the email of the person who instigated the change' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(instigator.email)
      end
    end
  end

  let(:instigator) { create(:person, email: 'instigator.user@digital.justice.gov.uk') }
  let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }

  describe ".new_profile_email" do
    subject(:mail) { described_class.new_profile_email(person, instigator.email).deliver_now }

    include_examples 'common mailer template elements'
    include_examples "common #{described_class} mail elements"

    it 'includes the person show url' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(person_url(person))
      end
    end
  end

  describe ".updated_profile_email" do

    let(:serialized_changes) { ChangesPresenter.new(person.changes).serialize }

    subject(:mail) do
      described_class.updated_profile_email(person, serialized_changes, instigator.email).deliver_now
    end

    before do
      person.primary_phone_number = '0123 456 789'
      person.building = ''
    end

    include_examples 'common mailer template elements'
    include_examples "common #{described_class} mail elements"

    it 'called with person, changes and instigator email' do
      mailing = double('mailing').as_null_object
      expect(described_class).to receive(:updated_profile_email).
        with(
          instance_of(Person),
          instance_of(String),
          instance_of(String)
        ).and_return(mailing)
      mail
    end

    it 'includes the person show url' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(person_url(person))
      end
    end

    context 'recipients' do
      it 'emails changed person' do
        expect(mail.to).to include 'test.user@digital.justice.gov.uk'
        expect(mail.cc).to be_empty
      end

      it 'emails changed person at new address and cc\'s old address when email changed' do
        person.email = 'changed.user@digital.justice.gov.uk'
        expect(mail.to).to include 'changed.user@digital.justice.gov.uk'
        expect(mail.cc).to include 'test.user@digital.justice.gov.uk'
      end
    end

    context 'mail content' do
      let(:changes_presenter) { ChangesPresenter.new(person.changes) }

      it 'includes list of presented changed person attributes' do
        changes_presenter.each_pair do |_field, change|
          %w(plain html).each do |part_type|
            expect(get_message_part(mail, part_type)).to have_content(/#{change}/m)
          end
        end
      end
    end
  end

  describe ".deleted_profile_email" do
    subject(:mail) { described_class.deleted_profile_email(person.email, person.name, instigator.email).deliver_now }

    include_examples 'common mailer template elements'
    include_examples "common #{described_class} mail elements"

    it 'includes the persons name' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(person.name)
      end
    end

  end

end
