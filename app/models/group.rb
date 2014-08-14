class Group < ActiveRecord::Base
  has_paper_trail ignore: [:updated_at, :created_at, :slug, :id]

  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :parent, class_name: 'Group'
  has_many :children, class_name: 'Group', foreign_key: 'parent_id'
  has_many :memberships, -> { includes(:person).order('people.surname')  }
  has_many :people, through: :memberships
  has_many :leaderships, -> { where(leader: true) }, class_name: 'Membership'
  has_many :non_leaderships,
    lambda {
      where(leader: false).includes(:person).
        order('people.surname ASC, people.given_name ASC')
    },
    class_name: 'Membership'
  has_many :leaders, through: :leaderships, source: :person
  has_many :non_leaders, through: :non_leaderships, source: :person

  validates :name, presence: true, uniqueness: { scope: :parent_id }

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

  def hierarchy
    @hierarchy ||= [].tap { |acc|
      node = self
      while node
        acc.unshift node
        node = node.parent
      end
    }
  end

  def leadership
    leaderships.first
  end

  def deletable?
    leaf_node? && memberships.reject(&:new_record?).empty?
  end

  def leaf_node?
    children.blank?
  end

  def all_people
    Person.find_by_sql(
    [
      'select distinct array_agg(role) as role_list, p.*
      from memberships m, people p
      where m.person_id = p.id AND group_id in (?)
      group by p.id;',  GroupHierarchy.new(self).to_group_id_list
    ]).
    sort_by(&:name).
    each { |p| p.role_names = p.role_list.compact.join(', ') }
  end

  def editable?
    parent.present?
  end

private

  def check_deletability
    unless deletable?
      errors[:base] << I18n.t('errors.groups.memberships_exist')
      return false
    end
  end

  delegate :image, to: :leader, prefix: true
  delegate :name, to: :leader, prefix: true
end
