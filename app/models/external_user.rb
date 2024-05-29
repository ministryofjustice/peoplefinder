# frozen_string_literal: true

# == Schema Information
#
# Table name: external_users
#
#  id           :integer not null, primary key
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
  attr_accessor :given_name, :surname, :slug, :email, :company, :admin

  validates :given_name, presence: true
  validates :surname, presence: true
  validates :slug, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, email: true

  include Sanitizable
  sanitize_fields :given_name, :surname, :company, strip: true, remove_digits: true
  sanitize_fields :email, strip: true, downcase: true
end
