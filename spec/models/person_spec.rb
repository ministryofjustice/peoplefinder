require 'rails_helper'

RSpec.describe Person, :type => :model do
  it { should validate_presence_of(:surname) }
end
