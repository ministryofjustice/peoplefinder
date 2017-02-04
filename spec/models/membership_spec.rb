# == Schema Information
#
# Table name: memberships
#
#  id         :integer          not null, primary key
#  group_id   :integer          not null
#  person_id  :integer          not null
#  role       :text
#  created_at :datetime
#  updated_at :datetime
#  leader     :boolean          default(FALSE)
#  subscribed :boolean          default(TRUE), not null
#

require 'rails_helper'

RSpec.describe Membership, type: :model do
  it { should validate_presence_of(:person).on(:update) }
  it { should validate_presence_of(:group).on(:update) }

  subject { described_class.new }

  it 'is not a leader by default' do
    expect(subject).not_to be_leader
  end

  it 'is suscribed by default' do
    expect(subject).to be_subscribed
  end
end
