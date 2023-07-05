require "rails_helper"

RSpec.describe PersonUpdater, type: :service do
  subject(:person_updater) { described_class.new(person:, current_user:, state_cookie: smc) }

  let(:person) do
    instance_double(
      Person,
      all_changes: { email: ["test.user@digital.justice.gov.uk", "changed.user@digital.justice.gov.uk"], membership_12: { group_id: [1, nil] } },
      save!: true,
      new_record?: false,
      notify_of_change?: false,
    )
  end

  let(:null_object) { instance_double(Object).as_null_object }
  let(:current_user) { instance_double(Person, email: "user@example.com") }

  context "when saving profile on update" do
    let(:smc) { instance_double StateManagerCookie, save_profile?: true, create?: false }

    before do
      allow(Group).to receive(:find).and_return null_object
    end

    describe "initialize" do
      it "raises an exception if person is a new record" do
        allow(person).to receive(:new_record?).and_return(true)
        expect { person_updater }.to raise_error(PersonUpdater::NewRecordError)
      end
    end

    describe "valid?" do
      it "delegates valid? to the person" do
        validity = double
        allow(person).to receive(:valid?).and_return(validity)
        expect(person_updater.valid?).to eq(validity)
      end
    end

    describe "update!" do
      it "saves the person" do
        expect(person).to receive(:save!)
        person_updater.update!
      end

      it "stores changes to person for use in update email" do
        allow(person).to receive(:notify_of_change?).and_return(true)
        expect(QueuedNotification).to receive(:queue!).with(person_updater)
        person_updater.update!
      end

      it "sends no update email if not required" do
        allow(person)
          .to receive(:notify_of_change?)
          .with(current_user)
          .and_return(false)
        expect(QueuedNotification).not_to receive(:queue!)
        person_updater.update!
      end

      it "sends creates a queued notification if required" do
        allow(person)
          .to receive(:notify_of_change?)
          .with(current_user)
          .and_return(true)

        expect(QueuedNotification).to receive(:queue!)
        person_updater.update!
      end
    end
  end

  context "when saving profile on create" do
    let(:smc) { instance_double StateManagerCookie, save_profile?: true, create?: true }

    it "queues a update notification" do
      allow(person).to receive(:notify_of_change?).and_return(true)
      expect(QueuedNotification).to receive(:queue!)
      person_updater.update!
    end
  end
end
