require 'rails_helper'

RSpec.describe PermittedDomain, type: :model do
  it { should validate_presence_of(:domain) }
end
