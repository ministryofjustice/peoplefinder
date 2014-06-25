require 'rails_helper'

RSpec.describe Membership, :type => :model do
  it { should validate_presence_of(:person) }
  it { should validate_presence_of(:group) }

  let!(:membership) { create(:membership) }

  it 'should not be a leader by default' do
    expect(membership.leader?).to be false
  end
end
