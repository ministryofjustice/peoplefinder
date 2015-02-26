require 'peoplefinder'

class Peoplefinder::Group < ActiveRecord::Base
  include Peoplefinder::Concerns::Hierarchical

  MAX_DESCRIPTION = 1000

  self.table_name = 'groups'

  has_paper_trail class_name: 'Peoplefinder::Version',
                  ignore: [:updated_at, :created_at, :slug, :id]

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

  validates :name, presence: true
  validates :slug, uniqueness: true
  validates :description, length: { maximum: MAX_DESCRIPTION }

  default_scope { order(name: :asc) }

  before_destroy :check_deletability

  def self.department
    roots.first
  end

  def to_s
    name
  end

  def deletable?
    leaf_node? && memberships.reject(&:new_record?).empty?
  end

  def all_people
    Peoplefinder::Person.all_in_groups(subtree_ids)
  end

  def editable_parent?
    new_record? || parent.present? || children.empty?
  end

  def slug_candidates
    candidates = [name]
    if parent.present?
      candidates <<  [parent.name, name]
      candidates <<  [parent.name, name_and_sequence]
    end
    candidates
  end

  def should_generate_new_friendly_id?
    name_changed?
  end

  def name_and_sequence
    slug = name.to_param
    sequence = Peoplefinder::Group.where('slug like ?', "#{slug}-%").count + 2
    "#{slug}-#{sequence}"
  end

private

  def check_deletability
    errors.add :base, :memberships_exist unless deletable?
  end

  delegate :image, to: :leader, prefix: true
  delegate :name, to: :leader, prefix: true
end
