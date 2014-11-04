require 'peoplefinder'

class Peoplefinder::Person < ActiveRecord::Base
  self.table_name = 'people'

  extend FriendlyId
  include Peoplefinder::Concerns::Searchable
  include Peoplefinder::Concerns::Completion
  include Peoplefinder::Concerns::Notifications
  include Peoplefinder::Concerns::WorkDays
  include Peoplefinder::Concerns::Authentication

  has_paper_trail ignore: [:updated_at, :created_at, :id, :slug]
  mount_uploader :image, Peoplefinder::ImageUploader

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :role_names

  validates :surname, presence: true
  has_many :memberships,
    -> { includes(:group).order('groups.name')  },
    dependent: :destroy
  has_many :groups, through: :memberships
  belongs_to :community

  accepts_nested_attributes_for :memberships,
    allow_destroy: true,
    reject_if: proc { |membership| membership['group_id'].blank? }

  default_scope { order(surname: :asc, given_name: :asc) }

  friendly_id :slug_source, use: :slugged

  before_save :sanitize_tags

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

  def phone
    return primary_phone_number if primary_phone_number.present?
    return secondary_phone_number if secondary_phone_number.present?
  end

  def support_email
    if groups.present?
      groups.first.team_email_address
    else
      Rails.configuration.support_email
    end
  end

  def community_name
    community.try(:name)
  end

  def self.tag_list
    Peoplefinder::Person.where('tags is not null').
      pluck(:tags).flatten.join(',').
      split(',').uniq.sort.join(',')
  end

private

  def group_path(hint_group)
    return [] if groups.empty?
    paths = groups.map(&:path)
    paths.find { |a| a.include?(hint_group) } || paths.first
  end

  def sanitize_tags
    if tags
      self.tags = tags.split(',').map { |tag|
        tag.strip.capitalize
      }.sort.join(',')
    end
  end
end
