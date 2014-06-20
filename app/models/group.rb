class Group < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :parent, class_name: 'Group'
  has_many :children, class_name: 'Group', foreign_key: 'parent_id'
  has_many :leaderships, -> { where(leader: true) }, class_name: 'Membership'
  has_many :leaders, through: :leaderships, source: :person

  validates_presence_of :name

  def self.orphans
    where(parent_id: nil)
  end

  def parent
    super || Department.instance
  end

  def to_s
    name
  end
end
