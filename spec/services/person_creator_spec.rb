require "rails_helper"

RSpec.describe PersonCreator, type: :service do
  include PermittedDomainHelper

  subject(:created_person) { described_class.new(person, current_user, smc) }

  let(:person) do
    instance_double(
      Person,
      email: "example.user.1@digital.justice.gov.uk",
      memberships: %w[MoJ],
      save!: true,
      new_record?: false,
      notify_of_change?: false,
    )
  end
  let(:current_user) { instance_double(Person, email: "user@example.com", id: 25) }

  context "when Saving a profile" do
    let(:smc) { instance_double StateManagerCookie, save_profile?: true }

    describe "valid?" do
      it "delegates valid? to the person" do
        validity = double
        allow(person).to receive(:valid?).and_return(validity)
        expect(created_person.valid?).to eq(validity)
      end
    end

    describe "create!" do
      context "with person membership defaults" do
        subject(:created_person) { described_class.new(person_object, current_user, smc).create! }

        let(:person_object) { build(:person) }

        it "adds membership of the top team if none specified" do
          create(:department)
          expect { created_person }.to change(person_object.memberships, :count).by(1)
          expect(person_object.memberships.first.group).to eql Group.department
        end
      end

      it "saves the person" do
        expect(person).to receive(:save!)
        created_person.create!
      end

      it "sends no new profile email if not required" do
        allow(person)
          .to receive(:notify_of_change?)
          .with(current_user)
          .and_return(false)
        expect(class_double(UserUpdateMailer).as_stubbed_const)
          .not_to receive(:new_profile_email)
        created_person.create!
      end

      it "creates a queued notification" do
        allow(person).to receive(:notify_of_change?).with(current_user).and_return(true)
        expect(QueuedNotification).to receive(:queue!)
        created_person.create!
      end
    end
  end

  context "when not saving a profile" do
    let(:smc) { instance_double StateManagerCookie, save_profile?: false }

    it "does not queue a notification" do
      allow(person).to receive(:notify_of_change?).with(current_user).and_return(false)
      expect(QueuedNotification).not_to receive(:queue!)
      created_person.create!
    end
  end
end
