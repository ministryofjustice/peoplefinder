require 'rails_helper'

RSpec.describe Peoplefinder::Group, type: :model do
  it { should have_many(:leaders) }
  it { should validate_presence_of(:team_email_address) }

  it "gives first orphaned groups as department" do
    parent = create(:department)
    create(:group, parent: parent)
    expect(described_class.department).to eql(parent)
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
      expect(department.slug_candidates).to eql(%w[MOJ])
    end

    it 'sets the team slug_candidate' do
      expect(team.slug_candidates).to eql(['CS', %w[MOJ CS], %w[MOJ CS-2]])
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
end
