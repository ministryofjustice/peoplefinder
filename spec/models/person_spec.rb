require 'rails_helper'

RSpec.describe Person, type: :model do
  include PermittedDomainHelper

  let(:person) { build(:person) }
  it { should validate_presence_of(:given_name).on(:update) }
  it { should validate_presence_of(:surname) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should have_many(:groups) }

  it { should respond_to(:pager_number) }
  it { should respond_to(:bulk_upload) }

  describe '.email' do
    it 'is converted to lower case' do
      person = create(:person, email: 'User.Example@digital.justice.gov.uk')
      expect(person.email).to eq 'user.example@digital.justice.gov.uk'
    end
  end

  describe '.email_address_with_name' do
    it 'returns name and email' do
      person = create(:person, given_name: 'Sue', surname: 'Boe', email: 'User.Example@digital.justice.gov.uk')
      expect(person.email_address_with_name).to eq 'Sue Boe <user.example@digital.justice.gov.uk>'
    end
  end

  context 'who has never logged in' do
    before { person.save }

    it 'is returned by .never_logged_in' do
      expect(described_class.never_logged_in).to include(person)
    end

    it 'is not returned by .logged_in_at_least_once' do
      expect(described_class.logged_in_at_least_once).not_to include(person)
    end
  end

  context 'who has logged in' do
    before do
      person.login_count = 1
      person.save!
    end

    it 'is not returned by .never_logged_in' do
      expect(described_class.never_logged_in).not_to include(person)
    end

    it 'is returned by .logged_in_at_least_once' do
      expect(described_class.logged_in_at_least_once).to include(person)
    end
  end

  describe '.name' do
    context 'with a given_name and surname' do
      let(:person) { build(:person, given_name: 'Jon', surname: 'von Brown') }

      it 'concatenates given_name and surname' do
        expect(person.name).to eql('Jon von Brown')
      end
    end

    context 'with a surname only' do
      let(:person) { build(:person, given_name: '', surname: 'von Brown') }

      it 'uses the surname' do
        expect(person.name).to eql('von Brown')
      end
    end

    context 'with surname containing digit' do
      let(:person) { build(:person, given_name: 'John', surname: 'Smith2') }
      it 'removes digit' do
        person.valid?
        expect(person.name).to eql('John Smith')
      end
    end
  end

  describe '.all_in_groups' do
    let(:groups) { create_list(:group, 3) }
    let(:people) { create_list(:person, 3) }

    it 'returns all people in any listed groups and .count_in_groups returns correct count' do
      people.zip(groups).each do |person, group|
        create :membership, person: person, group: group
      end
      group_ids = groups.take(2)
      result = described_class.all_in_groups(group_ids)
      expect(result).to include(people[0])
      expect(result).to include(people[1])
      expect(result).not_to include(people[2])

      count = described_class.count_in_groups(group_ids)
      expect(count).to eq(2)

      count = described_class.count_in_groups(group_ids, excluded_group_ids: groups.take(1))
      expect(count).to eq(1)
    end

    it 'concatenates all roles alphabetically with commas' do
      create :membership, person: people[0], group: groups[0], role: 'Prison chaplain'
      create :membership, person: people[0], group: groups[1], role: 'Head of crime'
      result = described_class.all_in_groups(groups.take(2))
      expect(result[0].role_names).to eq('Head of crime, Prison chaplain')
    end

    it 'omits blank roles' do
      create :membership, person: people[0], group: groups[0], role: 'Prison chaplain'
      create :membership, person: people[0], group: groups[1], role: ''
      result = described_class.all_in_groups(groups.take(2))
      expect(result[0].role_names).to eq('Prison chaplain')
    end

    it 'includes each person only once' do
      create :membership, person: people[0], group: groups[0], role: 'Prison chaplain'
      create :membership, person: people[0], group: groups[1], role: 'Head of crime'
      result = described_class.all_in_groups(groups.take(2))
      expect(result.length).to eq(1)
    end
  end

  context 'slug' do
    it 'generates from the first part of the email address if present' do
      person = create(:person, email: 'user.example@digital.justice.gov.uk')
      person.reload
      expect(person.slug).to eql('user-example')
    end
  end

  context 'search' do
    it 'deletes indexes' do
      expect(described_class.__elasticsearch__).to receive(:delete_index!).
        with(index: 'test_people')
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

  context 'with two memberships in the same group' do
    before do
      person.save!
      digital_services = create(:group, name: 'Digital Services')
      person.memberships.create(group: digital_services, role: 'Service Assessments Lead')
      person.memberships.create(group: digital_services, role: 'Head of Delivery')
      person.reload
    end

    it 'allows updates to those memberships' do
      expect(person.memberships.first.leader).to be false

      membership_attributes = person.memberships.first.attributes
      person.assign_attributes(
        memberships_attributes: {
          membership_attributes[:id] => membership_attributes.merge(leader: true)
        }
      )
      person.save!
      expect(person.reload.memberships.first.leader).to be true
    end

    it 'fires UpdateGroupMembersCompletionScoreJob for group on save' do
      expect(UpdateGroupMembersCompletionScoreJob).to receive(:perform_later).with(person.groups.first)
      person.save
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

  describe '#location' do
    it 'concatenates location_in_building, location, and city' do
      person.location_in_building = '99.99'
      person.building = '102 Petty France'
      person.city = 'London'
      expect(person.location).to eq('99.99, 102 Petty France, London')
    end

    it 'skips blank fields' do
      person.location_in_building = 'At home'
      person.building = ''
      person.city = nil
      expect(person.location).to eq('At home')
    end
  end

  describe 'valid?' do
    it 'is false when email invalid' do
      person.email = 'bad'
      expect(person.valid?).to be false
      expect(person.errors.messages[:email]).to eq ["isn’t valid"]
    end

    it 'is true when email valid with permitted domain' do
      person.email = 'test@digital.justice.gov.uk'
      expect(person.valid?).to be true
      expect(person.at_permitted_domain?).to be true
    end

    it 'is false when email does not have permitted domain' do
      person.email = 'test@example.com'
      expect(person.valid?).to be false
      expect(person.at_permitted_domain?).to be false
    end
  end

  describe '#notify_of_change?' do
    context 'when the email is not at a permitted domain' do
      before { allow(person).to receive(:at_permitted_domain?).and_return false }

      it 'is false if there is no reponsible person' do
        expect(person.notify_of_change?(nil)).to be false
      end

      it 'is false if the reponsible person is this person' do
        expect(person.notify_of_change?(person)).to be false
      end

      it 'is false if the reponsible person is a third party' do
        other_person = build(:person)
        expect(person.notify_of_change?(other_person)).to be false
      end
    end

    context 'when the email is at a permitted domain' do
      it 'is true if there is no reponsible person' do
        expect(person.notify_of_change?(nil)).to be true
      end

      it 'is false if the reponsible person is this person' do
        expect(person.notify_of_change?(person)).to be false
      end

      it 'is true if the reponsible person is a third party' do
        other_person = build(:person)
        expect(person.notify_of_change?(other_person)).to be true
      end
    end
  end

  describe 'profile_image' do
    context 'when there is a profile photo' do
      it 'delegates to the profile photo' do
        profile_photo = create(:profile_photo)
        person.profile_photo = profile_photo
        expect(person.profile_image).to eq(profile_photo.image)
      end
    end

    context 'when there is a legacy image but no profile photo' do
      it 'returns the mounted uploader' do
        person.assign_attributes image: 'cats.gif'
        expect(person.profile_image).to be_kind_of(ImageUploader)
      end
    end

    context 'when there is no image' do
      it 'returns nil' do
        person.assign_attributes image: nil
        expect(person.profile_image).to be_nil
      end
    end
  end

  describe '.last_reminder_email_at' do
    it 'is nil on create' do
      expect(person.last_reminder_email_at).to be_nil
    end

    it 'can be set to a datetime' do
      datetime = Time.now
      person.last_reminder_email_at = datetime
      expect(person.last_reminder_email_at).to eq(datetime)
    end
  end

  describe 'reminder_email_sent? within 30 days' do
    it 'is false on create' do
      expect(person.reminder_email_sent?(within: 30.days)).to be false
    end

    it 'is true when last_reminder_email_at is today' do
      person.last_reminder_email_at = Time.now
      expect(person.reminder_email_sent?(within: 30.days)).to be true
    end

    it 'is true when last_reminder_email_at is 30 days ago' do
      person.last_reminder_email_at = Time.now - 30.days
      expect(person.reminder_email_sent?(within: 30.days)).to be true
    end

    it 'is false when last_reminder_email_at is 31 days ago' do
      person.last_reminder_email_at = Time.now - 31.days
      expect(person.reminder_email_sent?(within: 30.days)).to be false
    end
  end

  describe '#bulk_upload' do
    before do
      digital_services = create(:group, name: 'Digital Services')
      person.memberships.build(group: digital_services)
      person.bulk_upload = true
    end

    it 'prevents enqueuing of group completion score update job' do
      expect(UpdateGroupMembersCompletionScoreJob).not_to receive(:perform_later)
      person.save
    end
  end

end
