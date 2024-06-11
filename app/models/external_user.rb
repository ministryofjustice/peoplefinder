# frozen_string_literal: true

# == Schema Information
#
# Table name: external_users
#
#  id           :integer  not null, primary key
#  email        :text
#  created_at   :datetime
#  updated_at   :datetime
#
class ExternalUser < ApplicationRecord
  include Sanitizable
  sanitize_fields :email, strip: true, downcase: true

  validates :email, presence: true, uniqueness: { case_sensitive: false }
end
