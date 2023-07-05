# == Schema Information
#
# Table name: permitted_domains
#
#  id         :integer          not null, primary key
#  domain     :string
#  created_at :datetime
#  updated_at :datetime
#

class PermittedDomain < ApplicationRecord
  validates :domain, presence: true, uniqueness: true # rubocop:disable Rails/UniqueValidationWithoutIndex
end
