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
    -> { includes(:person).order('people.surname') },
    dependent: :destroy
  has_many :people, through: :memberships
  has_many :leaderships, -> { where(leader: true) }, class_name: 'Membership'
  has_many :non_leaderships,
    -> { where(leader: false).includes(:person).order('people.surname ASC, people.given_name ASC') },
    class_name: 'Membership'
  has_many :leaders, through: :leaderships, source: :person
  has_many :non_leaders, through: :non_leaderships, source: :person

  validates :name, presence: true
  validates :slug, uniqueness: true
  validates :description, length: { maximum: MAX_DESCRIPTION }

  validate :not_second_root_group

  before_destroy :check_deletability

  default_scope { order(name: :asc) }

  scope :without_description, -> { unscoped.where(description: ['', nil]) }

  def self.department
    roots.first
  end

  def self.hierarchy_hash
    arrange(order: :name)
  end

  def self.percentage_with_description
    if count == 0
      0
    else
      100 - (without_description.count / count.to_f * 100).round(0)
    end
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

  def people_outside_subteams
    Person.all_in_groups([id]) - Person.all_in_groups(subteam_ids)
  end

  def people_outside_subteams_count
    Person.count_in_groups([id], excluded_group_ids: subteam_ids)
  end

  def leaderships_by_person
    leaderships.group_by(&:person)
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

  def description_reminder_email_sent? within_days:
    description_reminder_email_at.present? &&
      description_reminder_email_at.end_of_day >= within_days.day.ago
  end

  def send_description_reminder?
    !description_reminder_email_sent?(within_days: 30)
  end

  private

  def not_second_root_group
    if parent_id.nil?
      department = Group.department
      root_group_exists = department.present? && self != department
      errors.add(:parent_id, 'is required') if root_group_exists
    end
  end

  def name_and_sequence
    slug = name.to_param
    sequence = Group.where('slug like ?', "#{slug}-%").count + 2
    "#{slug}-#{sequence}"
  end

  def check_deletability
    errors.add :base, :memberships_exist unless deletable?
  end

  def subteam_ids
    subtree_ids - [id]
  end
end
