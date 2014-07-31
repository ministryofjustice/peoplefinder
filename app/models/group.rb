class Group < ActiveRecord::Base
  has_paper_trail ignore: [:updated_at, :created_at, :slug, :id]

  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :parent, class_name: 'Group'
  has_many :children, class_name: 'Group', foreign_key: 'parent_id'
  has_many :memberships, -> { includes(:person).order("people.surname")  }
  has_many :people, through: :memberships
  has_many :leaderships, -> { where(leader: true) }, class_name: 'Membership'
  has_many :non_leaderships,
    -> { where(leader: false).includes(:person).
         order("people.surname ASC, people.given_name ASC") },
    class_name: 'Membership'
  has_many :leaders, through: :leaderships, source: :person
  has_many :non_leaders, through: :non_leaderships, source: :person

  accepts_nested_attributes_for :memberships, allow_destroy: true,
    reject_if: proc { |membership| membership['person_id'].blank? }

  validates_presence_of :name

  default_scope { order(name: :asc) }

  before_destroy :check_deletability

  def self.departments
    where(parent_id: nil)
  end

  def to_s
    name
  end

  def level
    parent ? parent.level.succ : 0
  end

  def hierarchy(acc = [])
    acc = [self] + acc
    @hierarchy ||= parent ? parent.hierarchy(acc) : acc
  end

  def leadership
    leaderships.first
  end

  def assignable_people
    Person.where.not(id: memberships.pluck(:person_id))
  end

  def deletable?
    leaf_node? && memberships.reject(&:new_record?).empty?
  end

  def leaf_node?
    children.blank?
  end

  private

  def check_deletability
    unless deletable?
      errors[:base] << 'cannot be deleted until all the memberships have been removed'
      return false
    end
  end

  delegate :image, to: :leader, prefix: true
  delegate :name, to: :leader, prefix: true
end
