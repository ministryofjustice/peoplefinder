class Directorate < ActiveRecord::Base
	has_many :divisions
    after_initialize :init

    def init
      self.deleted  ||= false           #will set the default value only if it's nil
    end
end
