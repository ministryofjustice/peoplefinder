class Group < ActiveRecord::Base
  has_paper_trail ignore: [:updated_at, :created_at, :slug, :id]

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

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

  has_ancestry cache_depth: true

  validates :name, presence: true, uniqueness: { scope: :ancestry }

  default_scope { order(name: :asc) }

  before_destroy :check_deletability

  def self.department
    roots.first
  end

  def to_s
    name
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
      group by p.id;', subtree_ids
    ]).
    sort_by(&:name).
    each { |p| p.role_names = p.role_list.compact.join(', ') }
  end

  def editable_parent?
    new_record? || parent.present? || children.empty?
  end

  def slug_candidates
    candidates = [name]
    candidates <<  [parent.name, name] if parent.present?
    candidates
  end

  def should_generate_new_friendly_id?
    true
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
