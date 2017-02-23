require 'rails_helper'

RSpec.describe Admin::ManagementPolicy, type: :policy do

  subject { described_class.new(user, nil) }

  context 'for a super admin user' do
    let(:user) { build_stubbed(:person, super_admin: true) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:user_behavior_report) }
  end

  context 'for a regular user' do
    let(:user) { build_stubbed(:person, super_admin: false) }

    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:user_behavior_report) }
  end

  context 'for the readonly user' do
    let(:user) { build_stubbed(:readonly_user) }

    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:user_behavior_report) }
  end
end
