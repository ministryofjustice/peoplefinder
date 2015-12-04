class Group < ActiveRecord::Base
  include Concerns::Hierarchical
  include Concerns::Placeholder

  MAX_DESCRIPTION = 1000

  has_paper_trail class_name: 'Version',
                  ignore: [:updated_at, :created_at, :slug, :id]

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  def slug_candidates
    return [name] unless parent
    [name, [parent.name, name], [parent.name, name_and_sequence]]
  end

  def should_generate_new_friendly_id?
    name_changed?
  end

  has_many :memberships,
    -> { includes(:person).order('people.surname')  },
    dependent: :destroy
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

  before_destroy :check_deletability

  default_scope { order(name: :asc) }

  def self.department
    roots.first
  end

  def to_s
    name
  end

  def short_name
    acronym.present? ? acronym : name
  end

  def deletable?
    leaf_node? && memberships.reject(&:new_record?).empty?
  end

  def all_people
    Person.all_in_groups(subtree_ids)
  end

  def all_people_count
    Person.count_in_groups(subtree_ids)
  end

  def completion_score
    Rails.cache.fetch("#{id}-completion-score", expires_in: 1.hour) do
      people = all_people
      if people.blank?
        0
      else
        total_score = people.inject(0) { |total, person| total + person.completion_score }
        (total_score / people.length.to_f).round(0)
      end
    end
  end

  def editable_parent?
    new_record? || parent.present? || children.empty?
  end

  def subscribers
    memberships.subscribing.joins(:person).map(&:person)
  end

private

  def name_and_sequence
    slug = name.to_param
    sequence = Group.where('slug like ?', "#{slug}-%").count + 2
    "#{slug}-#{sequence}"
  end

  def check_deletability
    errors.add :base, :memberships_exist unless deletable?
  end
end
