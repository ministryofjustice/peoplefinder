class Person < ActiveRecord::Base
  extend FriendlyId
  include Searchable
  include Completion
  include Notifications
  include WorkDays

  has_paper_trail ignore: [:updated_at, :created_at, :id, :slug]
  mount_uploader :image, ImageUploader

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :role_names

  validates :surname, presence: true
  has_many :memberships,
    -> { includes(:group).order('groups.name')  },
    dependent: :destroy
  has_many :groups, through: :memberships

  accepts_nested_attributes_for :memberships,
    allow_destroy: true,
    reject_if: proc { |membership| membership['group_id'].blank? }

  default_scope { order(surname: :asc, given_name: :asc) }

  friendly_id :slug_source, use: :slugged

  def self.namesakes(person)
    where(surname: person.surname).
    where(given_name: person.given_name).
    where.not(id: person.id)
  end

  def name
    [given_name, surname].compact.join(' ').strip
  end

  def to_s
    name
  end

  def slug_source
    if email.present?
      email.split(/@/).first
    else
      name
    end
  end

  def role_and_group
    memberships.map { |m| [m.group_name, m.role].join(', ') }.join('; ')
  end

  def path(hint_group = nil)
    group_path(hint_group) + [self]
  end

private

  def group_path(hint_group)
    return [] if groups.empty?
    paths = groups.map(&:path)
    paths.find { |a| a.include?(hint_group) } || paths.first
  end
end
