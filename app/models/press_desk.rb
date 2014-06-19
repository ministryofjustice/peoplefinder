class PressDesk < ActiveRecord::Base
	validates :name, uniqueness: true, presence: true
	has_many :action_officers
	has_many :press_officers

	def email_output
		result = ""
		press_officers.each do |po|
			result << ";#{po.email}"
		end
		result
	end
end
