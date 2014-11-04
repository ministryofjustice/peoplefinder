require 'rails_helper'

RSpec.describe Peoplefinder::Person, type: :model do
  let(:person) { build(:person) }
  it { should validate_presence_of(:surname) }
  it { should have_many(:groups) }

  describe '.name' do
    before { person.surname = 'von Brown' }

    context 'with a given_name and surname' do
      it 'concatenates given_name and surname' do
        person.given_name = 'Jon'
        expect(person.name).to eql('Jon von Brown')
      end
    end

    context 'with a surname only' do
      it 'uses the surname' do
        expect(person.name).to eql('von Brown')
      end
    end
  end

  context 'slug' do
    it 'generates from the first part of the email address if present' do
      person = create(:person, email: 'user.example@digital.justice.gov.uk')
      person.reload
      expect(person.slug).to eql('user-example')
    end

    it 'generates from the name if there is no email' do
      person = create(:person, given_name: 'Bobby', surname: 'Tables')
      person.reload
      expect(person.slug).to eql('bobby-tables')
    end
  end

  context 'search' do
    it 'deletes indexes' do
      expect(described_class.__elasticsearch__).to receive(:delete_index!).
        with(index: 'test_peoplefinder-people')
      described_class.delete_indexes
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

    it 'writes the role and group as a string' do
      expect(person.role_and_group).to match(/Digital Services, Designer/)
      expect(person.role_and_group).to match(/Estates, Cleaner/)
    end
  end

  context 'path' do
    let(:person) { described_class.new }

    context 'when there are no memberships' do
      it 'contains only itself' do
        expect(person.path).to eql([person])
      end
    end

    context 'when there is one membership' do
      it 'contains the group path' do
        group_a = build(:group)
        group_b = build(:group)
        allow(group_b).to receive(:path) { [group_a, group_b] }
        person.groups << group_b
        expect(person.path).to eql([group_a, group_b, person])
      end
    end

    context 'when there are multiple group memberships' do
      let(:groups) { 4.times.map { build(:group) } }

      before do
        allow(groups[1]).to receive(:path) { [groups[0], groups[1]] }
        allow(groups[3]).to receive(:path) { [groups[2], groups[3]] }
        person.groups << groups[1]
        person.groups << groups[3]
      end

      it 'uses the first group path' do
        expect(person.path).to eql([groups[0], groups[1], person])
      end

      it 'uses the group hint to choose the path' do
        expect(person.path(groups[3])).to eql([groups[2], groups[3], person])
      end

      it 'uses the first group path if the hint is unhelpful' do
        expect(person.path(build(:group))).to eql([groups[0], groups[1], person])
      end
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

      it 'uses the primary phone number' do
        expect(person.phone).to eql(primary_phone_number)
      end
    end

    context 'with a blank primary and a valid secondary phone' do
      before do
        person.primary_phone_number = ''
        person.secondary_phone_number = secondary_phone_number
      end

      it 'uses the secondary phone number' do
        expect(person.phone).to eql(secondary_phone_number)
      end
    end
  end

  describe '.support_email' do
    let(:person) { create(:person) }
    subject { person.support_email }

    context 'when the the person is a member of a group' do
      before do
        person.groups << create(:group, team_email_address: '123@example.com')
      end

      it 'uses the group email address' do
        expect(subject).to eql('123@example.com')
      end
    end

    context 'when the person is not in a group' do
      it 'sets the application-wide support email' do
        expect(subject).to eql(Rails.configuration.support_email)
      end
    end
  end

  describe '#tag_list' do
    before do
      create(:person, tags: 'Ruby,Perl,Python')
      create(:person, tags: 'Java,Scala,Ruby,Python,Perl')
      create(:person, tags: '')
    end

    subject { described_class.tag_list }

    it 'returns a tag_list' do
      expect(subject).to eql('Java,Perl,Python,Ruby,Scala')
    end
  end
end
