require 'rails_helper'

RSpec.describe Peoplefinder::Membership, type: :model do
  it { should validate_presence_of(:person).on(:update) }
  it { should validate_presence_of(:group).on(:update) }

  let!(:membership) { create(:membership) }

  it 'is not be a leader by default' do
    expect(membership.leader?).to be false
  end
end
