# == Schema Information
#
# Table name: external_users
#
#  id           :integer  not null, primary key
#  given_name   :text
#  surname      :text
#  slug         :string
#  email        :text
#  company      :text
#  admin        :boolean  default(FALSE)
#  created_at   :datetime
#  updated_at   :datetime
#
require "rails_helper"

RSpec.describe ExternalUser, type: :model do
  # let(:external_user) { build(:external_user) }
  #
  # it { is_expected.to validate_presence_of(:given_name) }
  # it { is_expected.to validate_presence_of(:surname) }
  # it { is_expected.to validate_presence_of(:email) }
  # it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  # it { is_expected.to validate_presence_of(:company) }
  #
  # context "with a test factory" do
  #   describe "#create(:external_user)" do
  #     let(:external_user) { create(:external_user) }
  #
  #     it "creates a valid external user" do
  #       expect(external_user).to be_valid
  #     end
  #   end
  # end
end
