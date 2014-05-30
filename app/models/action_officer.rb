class ActionOfficer < ActiveRecord::Base
	# has_and_belongs_to_many :pqs
	has_many :action_officers_pqs
	has_many :pqs, :through => :action_officers_pqs
end
