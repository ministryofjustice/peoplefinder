class Group < ActiveRecord::Base
  has_paper_trail
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

  def self.find_by_slug(slug)
    if slug
      friendly.find(slug)
    else
      Department.instance
    end
  end

  def parent
    super || Department.instance
  end

  def to_s
    name
  end

  def editable?
    true
  end

  def type_of_children
    "Teams"
  end
end
