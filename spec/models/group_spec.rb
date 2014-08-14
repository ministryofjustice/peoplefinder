require 'rails_helper'

RSpec.describe Group, type: :model do
  it { should have_many(:leaders) }

  it "lists orphaned groups as departments" do
    parent = create(:group, parent: nil)
    create(:group, parent: parent)
    expect(described_class.departments.to_a).to eql([parent])
  end

  it "calculates its level" do
    parent = described_class.new
    child = described_class.new(parent: parent)
    expect(parent.level).to eql(0)
    expect(child.level).to eql(1)
  end

  it "knows about its ancestors" do
    grandparent = create(:group, parent: nil)
    parent = create(:group, parent: grandparent)
    child = create(:group, parent: parent)
    grandchild = create(:group, parent: child)

    expect(grandchild.hierarchy).to eql([grandparent, parent, child, grandchild])
  end

  it "knows when it has no ancestors" do
    department = create(:group, parent: nil)

    expect(department.hierarchy).to eql([department])
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

    it 'is only detable when there are no memberships' do
      group.memberships.create(person: create(:person))
      expect(group).not_to be_deletable
    end

    it 'is not detable when there are memberships' do
      group.memberships.create(person: create(:person))
      expect(group).not_to be_deletable
    end

    it 'is not detable when there are children' do
      create(:group, parent: group)
      expect(group.reload).not_to be_deletable
    end

    it 'is detable when there are unsaved memberships (e.g. in the groups#form)' do
      group.memberships.build
      expect(group).to be_deletable
    end
  end

  describe '.destroy' do
    let(:group) { create(:group) }

    it 'persists the record and add an error message when it is not deletable' do
      allow(group).to receive(:deletable?).once.and_return(false)
      group.destroy
      expect(group.errors[:base].to_s).to include('cannot be deleted')
    end

    it 'deletes the record when it is deletable' do
      allow(group).to receive(:deletable?).once.and_return(true)
      group.destroy
      expect { described_class.find(group) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '.all_people' do
    let(:team) { create(:group) }
    let(:subteam) { create(:group, parent: team) }

    let(:alice) { create(:person, surname: 'alice') }
    let(:bob) { create(:person, surname: 'bob') }

    subject { team.all_people }

    context 'with bob in the team' do
      before { team.people << bob }

      it 'has 1 membership' do
        expect(subject.length).to eq(1)
      end

      context 'and alice in the subteam' do
        before { subteam.people << alice }

        it 'has 2 membership' do
          expect(subject.length).to eq(2)
        end

        context 'and bob also in the subteam' do
          before { subteam.people << alice }

          it 'still has 2 memberships' do
            expect(subject.length).to eq(2)
          end

          it 'returns alice and bob in alphabetical order' do
            expect(subject.map(&:name)).to eql(%w[ alice bob ])
          end
        end
      end
    end
  end

  describe '.leadership' do
    it 'gets the first leader' do
      group = create(:group)
      leaderships = [create(:membership, group: group, leader: true)]
      expect(group.leadership).to eql(leaderships.first)
    end
  end

  describe '.editable?' do
    let(:department) { create(:department) }

    it 'does not have a parent' do
      expect(department.parent).to be_nil
    end

    it 'is not editable when there are no children (during application setup, for example)' do
      expect(department).to be_editable
    end

    it 'is editable when there are children' do
      create(:group, parent: department)
      expect(department.reload).not_to be_editable
    end
  end

  context "slugs" do
    let(:department) { create(:department, name: 'Ministry of Justice') }
    let(:team) { create(:group, name: 'A Team', parent: department) }
    let!(:subteam) { create(:group, name: 'A Subteam', parent: team) }

    it "generates slug from the hierarchy" do
      expect(subteam.hierarchical_slug).to eql('a-team/a-subteam')
      expect(team.hierarchical_slug).to eql('a-team')
      expect(department.hierarchical_slug).to eql('')
    end

    it "finds group by drilling down through slugs" do
      expect(described_class.by_hierarchical_slug('a-team/a-subteam').first).
        to eql(subteam)
    end

    it "finds the department for an empty list" do
      expect(described_class.by_hierarchical_slug('').first).to eql(department)
    end
  end
end
