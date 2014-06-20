class Membership < ActiveRecord::Base
  has_paper_trail

  belongs_to :person
  belongs_to :group
  validates :person, :group, presence: true

  delegate :name, to: :group
end
