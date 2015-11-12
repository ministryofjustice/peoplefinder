require 'rails_helper'

RSpec.describe PersonPolicy, type: :policy do
  let(:person) { build_stubbed(:person) }

  subject { described_class.new(user, person) }

  context 'for a regular user' do
    let(:user) { build_stubbed(:person) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:add_membership) }
  end

  context 'for the readonly user' do
    let(:user) { build_stubbed(:readonly_user) }

    it { is_expected.to permit_action(:show) }

    it { is_expected.not_to permit_action(:edit) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:add_membership) }
  end
end
