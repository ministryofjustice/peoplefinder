class WatchlistMember < ActiveRecord::Base
	validates :name, presence: true
	validates :email, presence: true, uniqueness: true, on: :create
  	validates_format_of :email,:with => Devise::email_regexp
  
	before_validation :strip_whitespace
	after_initialize :init

    def init
      self.deleted  ||= false           #will set the default value only if it's nil
    end
    
	def strip_whitespace
		self.name = self.name.strip unless self.name.nil?
		self.email = self.email.strip unless self.email.nil?
	end
end
