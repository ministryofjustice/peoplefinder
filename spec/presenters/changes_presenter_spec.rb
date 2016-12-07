require 'rails_helper'

RSpec.describe ChangesPresenter, type: :presenter do
  include PermittedDomainHelper

  let(:old_email) { 'test.user@digital.justice.gov.uk' }
  let(:new_email) { 'changed.user@digital.justice.gov.uk' }
  let(:person) do
    create(
      :person,
      email: old_email,
      location_in_building: '10.51',
      description: nil
    )
  end

  subject { described_class.new(person.changes) }

  it { is_expected.to be_a(described_class) }
  it { is_expected.to respond_to :changes }
  it { is_expected.to respond_to :raw }
  it { is_expected.to respond_to :[] }
  it { is_expected.to respond_to :each }
  it { is_expected.to respond_to :each_pair }

  describe 'delegation' do
    before { person.email = new_email }
    it 'delegates [] to #changes' do
      expect(subject[:email]).to eq subject.changes[:email]
    end
  end

  describe '#raw' do
    subject { described_class.new(person.changes).raw }
    before { person.email = new_email }
    it 'returns orginal changes' do
      is_expected.to be_a Hash
      expect(subject[:email].first).to eql old_email
    end
  end

  describe '#changes' do
    subject { described_class.new(person.changes).changes }

    let(:valid_format) do
      {
        email: { raw: [old_email, new_email], message: "Changed your email from #{old_email} to #{new_email}" },
        location_in_building: { raw: ['10.51', ''], message: 'Removed the location in building' },
        primary_phone_number: { raw: [nil, '01234, 567 890'], message: "Added a primary phone number" }
      }
    end

    before do
      person.email = new_email
      person.location_in_building = ''
      person.primary_phone_number = '01234, 567 890'
      person.description = ''
    end

    it { is_expected.to be_a Hash }
    it { is_expected.to respond_to :[] }
    it { is_expected.to respond_to :each }
    it { is_expected.to respond_to :each_pair }

    it 'returns expected format of data' do
      is_expected.to eql valid_format
    end

    it 'ignores empty strings as changes' do
      is_expected.to_not have_key :description
    end

  end

  describe '#serialize' do
    subject { described_class.new(person.changes).serialize }
    let(:valid_json_hash) do
      {
        data: {
          raw: {
            email: [old_email, new_email]
          }
        }
      }
    end

    before do
      person.email = 'changed.user@digital.justice.gov.uk'
      person.location_in_building = ''
      person.primary_phone_number = ' 01234, 567 890'
      person.description = ''
    end

    it { is_expected.to be_json }

    it 'returns JSON of raw changes only' do
      is_expected.to include_json(valid_json_hash)
      is_expected.not_to include_json(message: "Changed email from #{old_email} to #{new_email}")
    end

    it 'is deserializable' do
      expect { described_class.deserialize(subject) }.to_not raise_error
    end
  end

  describe '.deserialize' do
    let(:serialized_changes) { described_class.new(person.changes).serialize }
    subject { described_class.deserialize(serialized_changes) }

    it { is_expected.to be_instance_of described_class }
  end

end
