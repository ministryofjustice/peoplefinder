class ActionOfficer < ActiveRecord::Base
  validates :email, uniqueness: true, on: :create
  validates_format_of :email,:with => Devise::email_regexp

	has_many :action_officers_pqs
	has_many :pqs, :through => :action_officers_pqs

  before_validation :strip_whitespace

  def strip_whitespace
    self.name = self.name.strip unless self.name.nil?
    self.email = self.email.strip unless self.email.nil?
  end
end
