class Membership < ActiveRecord::Base
  belongs_to :person
  belongs_to :group
  validates :person, :group, presence: true
end
