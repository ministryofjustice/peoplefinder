# == Schema Information
#
# Table name: permitted_domains
#
#  id         :integer          not null, primary key
#  domain     :string
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe PermittedDomain, type: :model do
  it { should validate_presence_of(:domain) }
end
