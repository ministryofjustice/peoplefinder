class Membership < ActiveRecord::Base
  has_paper_trail ignore: [:updated_at, :created_at, :id]
  acts_as_paranoid

  belongs_to :person, touch: true
  belongs_to :group, touch: true
  validates :person, presence: true, uniqueness: { scope: :group }, on: :update
  validates :group, presence: true, uniqueness: { scope: :person }, on: :update

  delegate :name, to: :person, prefix: true
  delegate :image, to: :person, prefix: true
  delegate :name, to: :group, prefix: true
  delegate :hierarchy, to: :group
end
