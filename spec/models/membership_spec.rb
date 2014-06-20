require 'rails_helper'

RSpec.describe Membership, :type => :model do
  it { should validate_presence_of(:person) }
  it { should validate_presence_of(:group) }
end
