class Group < ActiveRecord::Base
  has_paper_trail ignore: [:updated_at, :created_at, :slug, :id]
  acts_as_paranoid

  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :parent, class_name: 'Group'
  has_many :children, class_name: 'Group', foreign_key: 'parent_id'
  has_many :memberships, dependent: :destroy
  has_many :people, through: :memberships
  has_many :leaderships, -> { where(leader: true) }, class_name: 'Membership'
  has_many :non_leaderships, -> { where(leader: false).includes(:person) }, class_name: 'Membership'
  has_many :leaders, through: :leaderships, source: :person
  has_many :non_leaders, through: :non_leaderships, source: :person

  validates_presence_of :name

  default_scope { order(name: :asc) }

  def self.departments
    where(parent_id: nil)
  end

  def to_s
    name
  end

  def level
    parent ? parent.level.succ : 0
  end

  def self.get_ancestors(group, ancestry=[])
    if group.parent.nil?
      return ancestry
    else
      ancestry << group.parent
      get_ancestors(group.parent, ancestry)
    end
  end

  def ancestors
    @ancestors ||= Group.get_ancestors(self).reverse
  end

  def with_ancestry
    ancestors << self
  end
end
