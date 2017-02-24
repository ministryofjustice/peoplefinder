require 'rails_helper'

RSpec.describe Admin::PersonUploadPolicy, type: :policy do
  let(:upload) { PersonUpload.new }

  subject { described_class.new(user, upload) }

  context 'for a super admin user' do
    let(:user) { build_stubbed(:person, super_admin: true) }

    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
  end

  context 'for a regular user' do
    let(:user) { build_stubbed(:person, super_admin: false) }

    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
  end

  context 'for the readonly user' do
    let(:user) { build_stubbed(:readonly_user) }

    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
  end
end
