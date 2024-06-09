# frozen_string_literal: true

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
class ExternalUser < ApplicationRecord
  include Sanitizable
  sanitize_fields :email, strip: true, downcase: true

  validates :email, presence: true, uniqueness: { case_sensitive: false }
end
