require 'rails_helper'

RSpec.describe Group, :type => :model do
  it { should have_many(:leaders) }

  it "should list orphaned groups as departments" do
    parent = create(:group, parent: nil)
    child = create(:group, parent: parent)
    expect(Group.departments.to_a).to eql([parent])
  end

  it "should calculate its level" do
    parent = Group.new
    child = Group.new(parent: parent)
    expect(parent.level).to eql(0)
    expect(child.level).to eql(1)
  end

  it "should know about its ancestors" do
    grandparent = create(:group, parent: nil)
    parent = create(:group, parent: grandparent)
    child = create(:group, parent: parent)
    grandchild = create(:group, parent: child)

    expect(grandchild.hierarchy).to eql([grandparent, parent, child, grandchild])
  end

  it "should know when it has no ancestors" do
    department = create(:group, parent: nil)

    expect(department.hierarchy).to eql([department])
  end

  describe '.assignable_people' do
    let(:group) { build(:group) }

    before do
      ['alice', 'bob', 'charlie'].each do |name|
         create(:person, surname: name)
      end
    end

    it 'should contain all people when a group has no memberships' do
      expect(group.assignable_people.length).to eql(3)
    end

    it 'should contain alice when bob and charlie are group members' do
      group.save!
      group.memberships.create(person: Person.find_by_surname('bob'))
      group.memberships.create(person:  Person.find_by_surname('charlie'))
      expect(group.assignable_people.first.surname).to eql('alice')
    end
  end

  describe '.deletable?' do
    let(:group) { create(:group) }

    it 'should only be detable when there are no memberships' do
      group.memberships.create(person: create(:person))
      expect(group).not_to be_deletable
    end

    it 'should not be detable when there are memberships' do
      group.memberships.create(person: create(:person))
      expect(group).not_to be_deletable
    end

    it 'should not be detable when there are children' do
      create(:group, parent: group)
      expect(group.reload).not_to be_deletable
    end

    it 'should be detable when there are unsaved memberships (e.g. in the groups#form)' do
      group.memberships.build
      expect(group).to be_deletable
    end
  end

  describe '.destroy' do
    let(:group) { create(:group) }

    it 'should persist the record and add an error message when it is not deletable' do
      allow(group).to receive(:deletable?).once.and_return(false)
      group.destroy
      expect(group.errors[:base].to_s).to include('cannot be deleted')
    end

    it 'should delete the record when it is deletable' do
      allow(group).to receive(:deletable?).once.and_return(true)
      group.destroy
      expect { Group.find(group) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
