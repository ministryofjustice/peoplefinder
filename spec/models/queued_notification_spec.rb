# == Schema Information
#
# Table name: queued_notifications
#
#  id                    :integer          not null, primary key
#  email_template        :string
#  session_id            :string
#  person_id             :integer
#  current_user_id       :integer
#  changes_json          :text
#  edit_finalised        :boolean          default(FALSE)
#  processing_started_at :datetime
#  sent                  :boolean          default(FALSE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require "rails_helper"

RSpec.describe QueuedNotification, type: :model do
  include PermittedDomainHelper

  describe "change_hash" do
    let(:my_hash) do
      { "json_class" => "ProfileChangesPresenter", "data" => { "raw" => { "given_name" => %w[John joanna], "surname" => %w[Doe Fawn] } } }
    end

    it "returns a deserialized version of changes_json" do
      qn = build :queued_notification, changes_json: my_hash.to_json
      expect(qn.changes_hash).to eq my_hash
    end
  end

  describe ".queue!" do
    let(:moj) { create :department }
    let(:ds) { create :group, name: "digital services", parent: moj }
    let(:tech) { create :group, name: "technology", parent: ds }
    let(:devs) { create :group, name: "devs", parent: tech }
    let(:archs) { create :group, name: "archs", parent: tech }

    let(:current_user) { create :person, given_name: "Liz", surname: "Truss", slug: "liz-truss", email: "liz@digital.justice.gov.uk" }
    let(:session_id) { "d9e2afcb4972cc2c963d8fe2802796b7" }

    before do
      person.given_name = "John"
      person.email = "john.jones@digital.justice.gov.uk"
      person.works_friday = false
    end

    context "when called by person creator" do
      let(:person) { create :person, given_name: "Stephen", surname: "Jones", slug: "stephen-richards", email: "sr@digital.justice.gov.uk" }
      let(:creator) { instance_double(PersonCreator, person:, current_user:, session_id:) }

      before do
        allow(creator).to receive(:is_a?).with(PersonCreator).and_return(true)
      end

      context "when no group changes (except default)" do
        context "when not final edit" do
          it "creates a new email template with edit finalised false" do
            allow(creator).to receive(:edit_finalised?).and_return(false)

            described_class.queue!(creator)

            expect(described_class.count).to eq 1
            qn = described_class.first

            expect(qn.person_id).to eq person.id
            expect(qn.current_user_id).to eq current_user.id
            expect(qn.email_template).to eq "new_profile_email"
            expect(qn.edit_finalised).to be false
            expect(qn.changes_hash).to eq expected_create_changes_hash
          end
        end

        # context no group changes
        context "when a final edit" do
          it "creates a new email template with edit finalised true" do
            allow(creator).to receive(:edit_finalised?).and_return(true)

            described_class.queue!(creator)

            expect(described_class.count).to eq 1
            qn = described_class.first

            expect(qn.person_id).to eq person.id
            expect(qn.current_user_id).to eq current_user.id
            expect(qn.email_template).to eq "new_profile_email"
            expect(qn.edit_finalised).to be true
            expect(qn.changes_hash).to eq expected_create_changes_hash
          end
        end
      end

      context "with group changes" do
        context "when not a final edit" do
          let(:person)  { build :person, given_name: "Stephen", surname: "Jones", slug: "stephen-richards", email: "sr@digital.justice.gov.uk" }

          it "creates a queued notification with group changes" do
            person.groups << devs
            person.groups << archs
            person.save!
            allow(creator).to receive(:edit_finalised?).and_return(false)

            described_class.queue!(creator)
            expect(described_class.count).to eq 1
            expect(described_class.first.changes_hash).to eq expected_create_changes_with_groups(devs, archs)
          end
        end
      end

      def expected_create_changes_hash
        {
          "json_class" => "ProfileChangesPresenter",
          "data" => {
            "raw" => {
              "given_name" => [nil, "Stephen"],
              "surname" => [nil, "Jones"],
              "email" => [nil, "sr@digital.justice.gov.uk"],
              "slug" => [nil, "stephen-richards"],
              "membership_#{moj.id}" => {
                "group_id" => [nil, moj.id],
              },
            },
          },
        }
      end

      def expected_create_changes_with_groups(devs, archs)
        {
          "json_class" => "ProfileChangesPresenter",
          "data" => {
            "raw" => {
              "given_name" => [nil, "John"],
              "surname" => [nil, "Jones"],
              "email" => [nil, "john.jones@digital.justice.gov.uk"],
              "slug" => [nil, "stephen-richards"],
              "works_friday" => [true, false],
              "membership_#{moj.id}" => {
                "group_id" => [nil, moj.id],
              },
              "membership_#{devs.id}" => {
                "group_id" => [nil, devs.id],
              },
              "membership_#{archs.id}" => {
                "group_id" => [nil, archs.id],
              },
            },
          },
        }
      end
    end

    context "when called by person updater" do
      let(:person) { create :person, given_name: "Stephen", surname: "Jones", slug: "stephen-richards", email: "sr@digital.justice.gov.uk" }
      let(:updater) { instance_double(PersonUpdater, person:, current_user:, session_id:) }

      context "with group changes" do
        before do
          person.groups << devs
          person.groups << archs
          person.save!
        end

        context "when not the final edit" do
          it "creates a queued notification with updated profile template and edit_finalsed false" do
            allow(updater).to receive(:edit_finalised?).and_return(false)

            described_class.queue!(updater)
            expect(described_class.count).to eq 1
            qn = described_class.first

            expect(qn.person_id).to eq person.id
            expect(qn.current_user_id).to eq current_user.id
            expect(qn.email_template).to eq "updated_profile_email"
            expect(qn.edit_finalised).to be false
          end
        end
      end
    end
  end

  context "when grouped items" do
    let(:qn_one) { create_notification("def", 1, 200, false, nil, false) }
    let(:qn_two) { create_notification("def", 1, 200, false, nil, false) }
    let(:qn_three) { create_notification("def", 1, 200, true, nil, false) }

    before do
      Timecop.freeze(30.minutes.ago) do
        # old session abc for person 1 current user 100 - sent
        create_notification("abc", 1, 100, false, Time.zone.now, true)
        create_notification("abc", 1, 100, false, Time.zone.now, true)
        create_notification("abc", 1, 100, true, Time.zone.now, true)

        # old session def for person 1, current user 200 - not sent, but finalised
        qn_one
        qn_two
        qn_three

        # old session efg for person 2, current user 200 - not sent, not finalised
        create_notification("efg", 2, 200, false, nil, false)
        create_notification("efg", 2, 200, false, nil, false)
      end

      # recent session jkl for person 3 current user 100 - not sent, but finalised
      create_notification("jkl", 3, 100, false, nil, false)
      create_notification("jkl", 3, 100, true, nil, false)

      # recent session mno for person 3 current user 100 - not sent, not finalised
      create_notification("mno", 3, 100, false, nil, false)
      create_notification("mno", 3, 100, false, nil, false)

      # recent_session pqr for person 4 current user 200 - sent, finalised
      create_notification("pqr", 3, 100, false, 10.minutes.ago, true)
      create_notification("pqr", 3, 100, true, 10.minutes.ago, true)

      # recent session stu started but not yet sent
      create_notification("stu", 3, 100, false, 10.minutes.ago, false)
      create_notification("stu", 3, 100, true, 10.minutes.ago, false)
    end

    def create_notification(session_id, person_id, user_id, finalised, processing_started_at, sent)
      create(:queued_notification,
             session_id:,
             person_id:,
             current_user_id: user_id,
             processing_started_at:,
             edit_finalised: finalised,
             sent:)
    end

    describe ".unsent_groups" do
      it "does not include any sent groups in the result set" do
        groups = described_class.unsent_groups
        expect(groups.map(&:session_id)).not_to include("abc")
        expect(groups.map(&:session_id)).not_to include("pqr")
      end

      it "does not include any groups in which processing has started even though sent is false" do
        groups = described_class.unsent_groups
        expect(groups.map(&:session_id)).not_to include("stu")
      end

      it "includes all unsent sessions older than the grace period" do
        groups = described_class.unsent_groups
        expect(groups.map(&:session_id)).to include("def")
        expect(groups.map(&:session_id)).to include("efg")
      end

      it "includes finalised groups which are newer than the grace period" do
        groups = described_class.unsent_groups
        expect(groups.map(&:session_id)).to include("jkl")
      end

      it "ncludes unfinalised groups which are newer than the grace period" do
        groups = described_class.unsent_groups
        expect(groups.map(&:session_id)).not_to include("mno")
      end
    end

    describe ".start_processing_grouped_item" do
      let(:grouped_item) { described_class.unsent_groups.find { |rec| rec.session_id == "def" } }

      it "returns all records in the group" do
        records = described_class.start_processing_grouped_item(grouped_item)
        expect(records.size).to eq 3
        expect(records).to include(qn_one, qn_two, qn_three)
      end

      it "timestamps all records in the group" do
        records = described_class.start_processing_grouped_item(grouped_item)
        records.each do |rec|
          expect(rec.processing_started_at).not_to be_nil
        end
      end
    end
  end

  context "when a private class method" do
    describe ".unfinalised_and_within_grace_period" do
      it "raises an error if called" do
        expect {
          described_class.unfinalised_and_within_grace_period?(nil)
        }.to raise_error NoMethodError, /private method .unfinalised_and_within_grace_period\?. called for/
      end
    end
  end
end
