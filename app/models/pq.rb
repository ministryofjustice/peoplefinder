class PQ < ActiveRecord::Base
	validates :uin , presence: true, uniqueness:true
	validates :raising_member_id, presence:true
	validates :question, presence:true
 	validates :press_interest, :inclusion => {:in => [true, false]}, if: :seen_by_press
  has_and_belongs_to_many :action_officers
 	#validates :finance_interest, :inclusion => {:in => [true, false]}, if: :seen_by_finance
end
