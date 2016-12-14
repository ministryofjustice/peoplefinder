require 'rails_helper'

RSpec.describe MembershipChangesPresenter, type: :presenter do
  include PermittedDomainHelper

  let(:person) do
    create(:person)
  end

  let(:team) do
    create(:group, name: 'Digital Services')
  end

  subject { described_class.new(person.memberships.map(&:changes)) }

  it { is_expected.to be_a(described_class) }
  it { is_expected.to respond_to :changes }
  it { is_expected.to respond_to :raw }
  it { is_expected.to respond_to :[] }
  it { is_expected.to respond_to :each }
  it { is_expected.to respond_to :each_pair }

  describe '#raw' do
    subject { described_class.new(person.memberships.map(&:changes)).raw }
    before do
      person.email = 'test.user@digital.justice.gov.uk'
      person.memberships << build(:membership, person: person, group: team)
      byebug
    end

    it 'returns orginal changes' do
      is_expected.to be_a Hash
      expect(subject[:email].first).to eql old_email
    end
  end

end
