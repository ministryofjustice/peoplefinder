require "rails_helper"

RSpec.describe Admin::ManagementPolicy, type: :policy do
  subject { described_class.new(user, nil) }

  before do
    stub_const("ACTIONS", %w[show user_behavior_report generate_user_behavior_report].map(&:to_sym))
  end

  context "with a super admin user" do
    let(:user) { build_stubbed(:person, super_admin: true) }

    ACTIONS.each do |action|
      it { is_expected.to permit_action(action) }
    end
  end

  context "with a regular user" do
    let(:user) { build_stubbed(:person, super_admin: false) }

    ACTIONS.each do |action|
      it { is_expected.not_to permit_action(action) }
    end
  end

  context "with the readonly user" do
    let(:user) { build_stubbed(:readonly_user) }

    ACTIONS.each do |action|
      it { is_expected.not_to permit_action(action) }
    end
  end
end
