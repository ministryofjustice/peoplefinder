class Membership < ActiveRecord::Base
  has_paper_trail ignore: [:updated_at, :created_at, :id]
  acts_as_paranoid

  belongs_to :person, touch: true
  belongs_to :group, touch: true
  validates :person, :group, presence: true

  delegate :name, to: :group
  delegate :name, to: :person, prefix: true
  delegate :name, to: :group, prefix: true
end
