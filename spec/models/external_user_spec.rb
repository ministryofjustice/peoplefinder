# == Schema Information
#
# Table name: external_users
#
#  id           :integer  not null, primary key
#  email        :text
#  created_at   :datetime
#  updated_at   :datetime
#
require "rails_helper"

RSpec.describe ExternalUser, type: :model do
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
end
