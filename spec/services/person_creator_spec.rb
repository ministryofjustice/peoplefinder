require 'rails_helper'

RSpec.describe PersonCreator, type: :service do
  include PermittedDomainHelper
  let(:person) do
    double(
      'Person',
      email: 'example.user.1@digital.justice.gov.uk',
      memberships: ['MoJ'],
      save!: true,
      new_record?: false,
      notify_of_change?: false
    )
  end
  let(:current_user) { double('Current User', email: 'user@example.com', id: 25) }
  subject { described_class.new(person: person, current_user: current_user, state_cookie: smc) }

  context 'Saving profile' do
    let(:smc) { double StateManagerCookie, save_profile?: true }

    describe 'valid?' do
      it 'delegates valid? to the person' do
        validity = double
        expect(person).to receive(:valid?).and_return(validity)
        expect(subject.valid?).to eq(validity)
      end
    end

    describe 'create!' do
      context 'person membership defaults' do
        subject { described_class.new(person: person_object, current_user: current_user, state_cookie: smc).create! }
        let!(:moj) { create(:department) }
        let(:person_object) { build(:person) }

        it 'adds membership of the top team if none specified' do
          expect { subject }.to change(person_object.memberships, :count).by(1)
          expect(person_object.memberships.first.group).to eql Group.department
        end
      end

      it 'saves the person' do
        expect(person).to receive(:save!)
        subject.create!
      end

      it 'sends no new profile email if not required' do
        allow(person).
          to receive(:notify_of_change?).
          with(current_user).
          and_return(false)
        expect(class_double('UserUpdateMailer').as_stubbed_const).
          to receive(:new_profile_email).
          never
        subject.create!
      end

      it 'creates a queued notification' do
        allow(person).to receive(:notify_of_change?).with(current_user).and_return(true)
        expect(QueuedNotification).to receive(:queue!)
        subject.create!
      end
    end
  end

  context 'Not saving profile' do
    let(:smc) { double StateManagerCookie, save_profile?: false }

    it 'does not  a notification' do
      allow(person).to receive(:notify_of_change?).with(current_user).and_return(true)
      expect(QueuedNotification).to receive(:queue!)
      subject.create!
    end
  end

end
