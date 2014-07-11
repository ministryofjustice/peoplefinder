class Agreement < ActiveRecord::Base
  belongs_to :manager, class_name: 'User'
  belongs_to :jobholder, class_name: 'User'

  validates :manager, presence: true
  validates :jobholder, presence: true

  def manager_email=(email)
    self.manager = User.for_email(email)
  end

  def jobholder_email=(email)
    self.jobholder = User.for_email(email)
  end
end
