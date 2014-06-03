class ActionOfficer < ActiveRecord::Base
  validates :email, uniqueness: true

  # has_and_belongs_to_many :pqs
	has_many :action_officers_pqs
	has_many :pqs, :through => :action_officers_pqs

  before_validation :strip_whitespace

  def strip_whitespace
    self.name = self.name.strip unless self.name.nil?
    self.email = self.email.strip unless self.email.nil?
  end
end
