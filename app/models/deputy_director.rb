class DeputyDirector < ActiveRecord::Base
	validates :division_id, presence: true

	has_many :action_officers
	belongs_to :division
    after_initialize :init

    def init
      self.deleted  ||= false           #will set the default value only if it's nil
    end
end
