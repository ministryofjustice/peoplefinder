class ActionOfficer < ActiveRecord::Base
  validates :email, uniqueness: true, on: :create
  validates_format_of :email,:with => Devise::email_regexp
  validates :deputy_director_id, presence: true
  
	has_many :action_officers_pqs
	has_many :pqs, :through => :action_officers_pqs

	belongs_to :deputy_director
  
  before_validation :strip_whitespace
  after_initialize :init


  def init
    self.deleted  ||= false           #will set the default value only if it's nil
  end

  def name_with_div
    if deputy_director.nil?
      name
    else
      "#{name} (#{deputy_director.division.name})" 
    end
  end

  def strip_whitespace
    self.name = self.name.strip unless self.name.nil?
    self.email = self.email.strip unless self.email.nil?
  end
end
