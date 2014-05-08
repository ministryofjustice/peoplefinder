class PQ < ActiveRecord::Base
	validates :PIN , presence: true, uniqueness:true
	validates :RaisingMemberID, presence:true
	validates :Question, presence:true
end
