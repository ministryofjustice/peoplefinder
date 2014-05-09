class PQ < ActiveRecord::Base
	validates :pin , presence: true, uniqueness:true
	validates :raising_member_id, presence:true
	validates :question, presence:true
end
