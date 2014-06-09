class ActionOfficersPq < ActiveRecord::Base
  belongs_to :pq
	belongs_to :action_officer
end