require 'rails_helper'

RSpec.describe Person, :type => :model do
  let(:person) { build(:person) }
  it { should validate_presence_of(:surname) }
  it { should have_many(:groups) }

  describe '.name' do
    before { person.surname = 'von Brown' }

    context 'with a given_name and surname' do
      it 'should concatenate given_name and surname' do
        person.given_name = 'Jon'
        expect(person.name).to eql('Jon von Brown')
      end
    end

    context 'with a surname only' do
      it 'should use the surname' do
        expect(person.name).to eql('von Brown')
      end
    end
  end

  context "completion score" do
    it "should be 0 if all fields are empty" do
      person = Person.new
      expect(person.completion_score).to eql(0)
      expect(person).to be_incomplete
    end

    it "should be 50 if half the fields are filled" do
      person = Person.new(
        given_name: "Bobby",
        surname: "Tables",
        email: "user.example@digital.justice.gov.uk",
        primary_phone_number: "020 7946 0123",
      )
      expect(person.completion_score).to eql(50)
      expect(person).to be_incomplete
    end

    it "should be 100 if all fields are filled" do
      person = Person.new(
        given_name: "Bobby",
        surname: "Tables",
        email: "user.example@digital.justice.gov.uk",
        primary_phone_number: "020 7946 0123",
        secondary_phone_number: "07700 900123",
        location: "London",
        description: "I am a real person"
      )
      person.groups << build(:group)
      expect(person.completion_score).to eql(100)
      expect(person).not_to be_incomplete
    end
  end

  context "slug" do
    it "should be generated from the first part of the email address if present" do
      person = create(:person, email: "user.example@digital.justice.gov.uk")
      person.reload
      expect(person.slug).to eql("user-example")
    end

    it "should be generated from the name if there is no email" do
      person = create(:person, given_name: "Bobby", surname: "Tables")
      person.reload
      expect(person.slug).to eql("bobby-tables")
    end
  end

  context "search" do
    it "should delete indexes" do
      expect(Person.__elasticsearch__).to receive(:delete_index!).with({ index: "test_people" })
      Person.delete_indexes
    end
  end

  context 'elasticsearch indexing helpers' do
    before do
      person.save!
      digital_services = create(:group, name: 'Digital Services')
      estates = create(:group, name: 'Estates')
      person.memberships.create(group: estates, role: 'Cleaner')
      person.memberships.create(group: digital_services, role: 'Designer')
    end

    it 'should write the role and group as a string' do
      expect(person.role_and_group).to match(/Digital Services, Designer/)
      expect(person.role_and_group).to match(/Estates, Cleaner/)
    end
  end

  context "hierarchy" do
    let(:person) { Person.new }

    context "when there are no memberships" do
      it "should contain only itself" do
        expect(person.hierarchy).to eql([person])
      end
    end

    context "when there is one membership" do
      it "should contain the group's hierarchy" do
        group_a = Group.new
        group_b = Group.new
        allow(group_b).to receive(:hierarchy) { [group_a, group_b] }
        person.groups << group_b
        expect(person.hierarchy).to eql([group_a, group_b, person])
      end
    end

    context "when there are multiple group memberships" do
      let(:groups) { 4.times.map { Group.new } }

      before do
        allow(groups[1]).to receive(:hierarchy) { [groups[0], groups[1]] }
        allow(groups[3]).to receive(:hierarchy) { [groups[2], groups[3]] }
        person.groups << groups[1]
        person.groups << groups[3]
      end

      it "should use the first group's hierarchy" do
        expect(person.hierarchy).to eql([groups[0], groups[1], person])
      end

      it "should use the group hint to choose the hierarchy" do
        expect(person.hierarchy(groups[3])).to eql([groups[2], groups[3], person])
      end

      it "should use the first group's hierarchy if the hint is unhelpful" do
        expect(person.hierarchy(Group.new)).to eql([groups[0], groups[1], person])
      end
    end
  end

  describe '.assignable groups' do
    before do
      ['apples', 'bananas', 'cherries'].each do
        |fruit| create(:group, name: fruit)
      end
    end

    it 'should contain all groups when a person has no memberships' do
      expect(person.assignable_groups.length).to eql(3)
    end

    it 'should contain apples when a person is a member of bananas and cherries' do
      person.save!
      person.memberships.create(group: Group.find_by_name('bananas'))
      person.memberships.create(group:  Group.find_by_name('cherries'))
      expect(person.assignable_groups.first.name).to eql('apples')
    end
  end

  describe '.phone' do
    let(:person) { create(:person) }
    let(:primary_phone_number) { '0207-123-4567' }
    let(:secondary_phone_number) { '0208-999-8888' }

    context 'with a primary and secondary phone' do
      before do
        person.primary_phone_number = primary_phone_number
        person.secondary_phone_number = secondary_phone_number
      end

      it 'should use the primary phone number' do
        expect(person.phone).to eql(primary_phone_number)
      end
    end

    context 'with a blank primary and a valid secondary phone' do
      before do
        person.primary_phone_number = ''
        person.secondary_phone_number = secondary_phone_number
      end

      it 'should use the secondary phone number' do
        expect(person.phone).to eql(secondary_phone_number)
      end
    end
  end
end
