class Membership < ActiveRecord::Base
  has_paper_trail ignore: [:updated_at, :created_at, :id]
  acts_as_paranoid

  belongs_to :person
  belongs_to :group
  validates :person, :group, presence: true

  delegate :name, to: :group
end
