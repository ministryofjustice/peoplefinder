class ActionOfficer < ActiveRecord::Base
	validates :name, presence: true, uniqueness:true
	validates :email, presence: true, uniqueness:true
  has_and_belongs_to_many :pqs
end
