# == Schema Information
#
# Table name: groups
#
#  id                            :integer          not null, primary key
#  name                          :text
#  created_at                    :datetime
#  updated_at                    :datetime
#  slug                          :string
#  description                   :text
#  ancestry                      :text
#  ancestry_depth                :integer          default(0), not null
#  acronym                       :text
#  description_reminder_email_at :datetime
#  members_completion_score      :integer
#

require 'rails_helper'

RSpec.describe Group, type: :model do
  include PermittedDomainHelper

  it { should have_many(:leaders) }
  it { should validate_length_of(:description).is_at_most(1000) }

  it "gives first orphaned groups as department" do
    parent = create(:department)
    create(:group, parent: parent)
    expect(described_class.department).to eql(parent)
  end

  it "only allows creation of one group with no parent" do
    create(:department)
    group = build(:group, parent: nil)
    expect(group.valid?).to eq false
    expect(group.errors[:parent_id]).to eq ['is required']
    expect { group.save! }.to raise_error(Exception)
  end

  context '#after_save' do
    let!(:group) { build(:group, parent: nil) }

    it 'calls method to enqueue job for completion score update' do
      expect(UpdateGroupMembersCompletionScoreJob).to receive(:perform_later).with(group)
      group.save!
    end

    it 'enqueues job to update completion scores for self and all ancestors/parents' do
      expect { group.save! }.to have_enqueued_job
    end
  end

  it "knows about its ancestors" do
    grandparent = create(:group, parent: nil)
    parent = create(:group, parent: grandparent)
    child = create(:group, parent: parent)
    grandchild = create(:group, parent: child)

    expect(grandchild.path.to_a).to eql([grandparent, parent, child, grandchild])
  end

  it "knows when it has no ancestors" do
    department = create(:group, parent: nil)

    expect(department.path.to_a).to eql([department])
  end

  it "does not permit cyclic graphs" do
    a = create(:group)
    b = create(:group, parent: a)
    c = create(:group, parent: b)

    a.parent = c
    expect(a).not_to be_valid
  end

  describe '.leaf_node?' do
    let(:group) { create(:group) }

    it "knows when it is a leaf_node (no children)" do
      expect(group).to be_leaf_node
    end

    it "knows when it is not a leaf_node (no children)" do
      expect(group).to be_leaf_node
    end
  end

  describe '.deletable?' do
    let(:group) { create(:group) }

    it 'is only deletable when there are no memberships' do
      group.memberships.create(person: create(:person))
      expect(group).not_to be_deletable
    end

    it 'is not deletable when there are memberships' do
      group.memberships.create(person: create(:person))
      expect(group).not_to be_deletable
    end

    it 'is not deletable when there are children' do
      create(:group, parent: group)
      expect(group.reload).not_to be_deletable
    end

    it 'is detable when there are unsaved memberships (e.g. in the groups#form)' do
      group.memberships.build
      expect(group).to be_deletable
    end
  end

  describe '.destroy' do
    let!(:group) { create(:group) }

    it 'persists the record and add an error message when it is not deletable' do
      allow(group).to receive(:deletable?).once.and_return(false)
      group.destroy
      expect(group.errors[:base].to_s).to include('cannot be deleted')
    end

    it 'deletes the record when it is deletable' do
      allow(group).to receive(:deletable?).once.and_return(true)
      group.destroy
      expect { described_class.find(group.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not enqueue completion score update job' do
      expect { group.destroy! }.not_to have_enqueued_job.on_queue('low_priority')
    end

  end

  describe 'team with subteam' do
    let(:team) { create(:group) }
    let(:cache_id) { "#{team.id}-completion-score" }
    let(:subteam) { create(:group, parent: team) }

    let(:alice) { create(:person, given_name: 'alice', surname: 'smith') }
    let(:bob) { create(:person, given_name: 'bob', surname: 'smith', city: 'Winchester') }

    before do
      Rails.cache.delete(cache_id)
    end

    context 'with no people in team or subteam' do
      it 'has empty all_people' do
        expect(team.all_people).to be_empty
      end

      it 'has all_people_count of zero' do
        expect(team.all_people_count).to eq(0)
      end

      it 'has empty people_outside_subteams' do
        expect(team.people_outside_subteams).to be_empty
      end

      it 'has people_outside_subteams_count of zero' do
        expect(team.people_outside_subteams_count).to eq(0)
      end

      context 'after update_members_completion_score! called' do
        it 'has members_completion_score equal to zero' do
          team.update_members_completion_score!
          expect(team.members_completion_score).to eq(0)
        end
      end
    end

    context 'with bob in the team' do
      before do
        team.people << bob
        bob.reload
      end

      context 'and bob is a team leader' do

        before do
          bob.memberships.first.update(leader: true)
        end

        it 'has .leaderships return array containing bob\'s membership' do
          expect(team.leaderships.to_a).to eq [bob.memberships.first]
        end

        it 'has .leaderships_by_person return hash containing bob and his membership' do
          expect(team.leaderships_by_person[bob]).to eq [bob.memberships.first]
        end

        it 'has people_outside_subteams_count of zero' do
          expect(team.people_outside_subteams_count).to eq(0)
        end

        it 'has zero length people_outside_subteams array' do
          expect(team.people_outside_subteams.length).to eq(0)
        end
      end

      it 'has 1 in all_people array' do
        expect(team.all_people.length).to eq(1)
      end

      it 'has items in all_people Person relation that have role_names' do
        expect(team.all_people.first).to respond_to :role_names
      end

      it "has all_people_count of 1" do
        expect(team.all_people_count).to eq(1)
      end

      it 'has 1 in people_outside_subteams array' do
        expect(team.people_outside_subteams.length).to eq(1)
      end

      it 'has items in people_outside_subteams array that have role_names' do
        expect(team.people_outside_subteams.first.respond_to?(:role_names)).to be true
      end

      it 'has people_outside_subteams_count of 1' do
        expect(team.people_outside_subteams_count).to eq(1)
      end

      context 'after update_members_completion_score! called' do
        it 'has members_completion_score equal to bob\'s completion_score' do
          team.update_members_completion_score!
          expect(team.members_completion_score).to eq(bob.completion_score)
        end
      end

      context 'and alice in the subteam' do
        before do
          subteam.people << alice
          alice.reload
        end

        it 'has 2 in all_people array' do
          expect(team.all_people.length).to eq(2)
        end

        it 'has all_people_count of 2' do
          expect(team.all_people_count).to eq(2)
        end

        it 'has 1 in people_outside_subteams' do
          expect(team.people_outside_subteams.length).to eq(1)
        end

        it 'has people_outside_subteams_count of 1' do
          expect(team.people_outside_subteams_count).to eq(1)
        end

        context 'after update_members_completion_score! called' do
          it 'has members_completion_score equal to average of bob and alice\'s completion_score' do
            team.update_members_completion_score!
            average_score = ((bob.completion_score + alice.completion_score) / 2.0).round(0)
            expect(team.members_completion_score).to eq(average_score)
          end
        end

        context 'and bob also in the subteam' do
          before { subteam.people << bob }

          it 'has 2 in all_people array' do
            expect(team.all_people.length).to eq(2)
          end

          it 'has all_people_count of 2' do
            expect(team.all_people_count).to eq(2)
          end

          it 'has empty people_outside_subteams' do
            expect(team.people_outside_subteams).to be_empty
          end

          it 'has people_outside_subteams_count of zero' do
            expect(team.people_outside_subteams_count).to eq(0)
          end

          it 'returns alice and bob in alphabetical order' do
            expect(team.all_people.map(&:name)).to eql(['alice smith', 'bob smith'])
          end

          context 'after update_members_completion_score! called' do
            it 'has members_completion_score equal to average of bob and alice\'s completion_score' do
              team.update_members_completion_score!
              average_score = ((bob.completion_score + alice.completion_score) / 2.0).round(0)
              expect(team.members_completion_score).to eq(average_score)
            end
          end
        end
      end
    end
  end

  describe '.editable_parent?' do
    let(:department) { create(:department) }

    it 'checks that there is no parent' do
      expect(department.parent).to be_nil
    end

    it 'allows editing of the parent when there are no children (during application setup, for example)' do
      expect(department.editable_parent?).to be true
    end

    it 'prevents editing of the parent when there are children' do
      create(:group, parent: department)
      expect(department.reload.editable_parent?).to be false
    end
  end

  describe '.slug_candidates' do
    let(:department) { create(:department, name: 'MOJ') }
    let(:team) { create(:group, parent: department, name: 'CS') }

    it 'sets the department slug_candidate' do
      expect(department.slug_candidates).to eql(%w(MOJ))
    end

    it 'sets the team slug_candidate' do
      expect(team.slug_candidates).to eql(['CS', %w(MOJ CS), %w(MOJ CS-2)])
    end
  end

  describe '.should_generate_new_friendly_id?' do
    let!(:team) { create(:group, name: 'Digital Services') }

    context 'when the team is first created' do
      it 'sets the slug' do
        expect(team.slug).to eql('digital-services')
      end

      context 'when the team name is changed' do
        it 'gets the updated slug when the name is changed' do
          team.update_attributes(name: 'Analog Services')
          expect(team.reload.slug).to eql('analog-services')
        end
      end
    end

    context 'when a group with a duplicate (name and parent name) is added' do
      let!(:first_duplicate) { create(:group, name: 'Digital Services') }

      it 'prepends the parent' do
        expect(first_duplicate.slug).to eql('ministry-of-justice-digital-services')
      end

      context 'when a second duplicate (name and parent name) is added' do
        let(:second_duplicate) { create(:group, name: 'Digital Services') }

        it 'appends -1 to the group name' do
          expect(second_duplicate.slug).to eql('ministry-of-justice-digital-services-2')
        end
      end
    end
  end

  describe '#subscribers' do
    it 'returns all members with the subscribed flag set' do
      group = create(:group)
      subscriber_a = create(:person)
      subscriber_b = create(:person)
      non_subscriber = create(:person)
      _non_member = create(:person)
      create :membership, person: subscriber_a, group: group, subscribed: true
      create :membership, person: subscriber_b, group: group, subscribed: true
      create :membership, person: non_subscriber, group: group, subscribed: false

      expect(group.subscribers).to match_array([subscriber_a, subscriber_b])
    end
  end

  describe '.short_name' do
    let(:dept_name) { 'HM Courts and Tribunals Service' }
    let(:dept_acronym) { 'HMCTS' }
    let(:dept) { create(:group, name: dept_name) }

    context 'if a group does not have an acronym' do
      it 'returns the full name' do
        expect(dept.short_name).to eql(dept_name)
      end
    end

    context 'if a group does have an acronym' do
      it 'returns the acronym' do
        dept.acronym = dept_acronym
        expect(dept.short_name).to eql(dept_acronym)
      end
    end
  end

  describe '.percentage_with_description' do
    it 'is correct' do
      expect(described_class.percentage_with_description).to eq 0

      parent = create(:department)
      create(:group, parent: parent)
      expect(described_class.percentage_with_description).to eq 0

      create(:group, parent: parent, description: 'We do this')
      expect(described_class.percentage_with_description).to eq 33
    end
  end

  describe '#average_completion_score' do
    let(:team) { create(:group) }
    let(:subteam) { create(:group, parent: team) }

    it 'returns 0 when no one exists in subtree' do
      expect(team.average_completion_score).to be 0
    end

    it 'returns average completion score of all people in group and subtree' do
      create(:membership, group: team, person: create(:person))
      create(:membership, group: team, person: create(:person))
      create(:membership, group: subteam, person: create(:person, city: 'Wherever'))
      expect(team.average_completion_score).to be_between(47, 49)
      expect(subteam.average_completion_score).to be_between(55, 58)
    end

  end

end
