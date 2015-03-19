require 'peoplefinder'

class Peoplefinder::Person < ActiveRecord::Base
  self.table_name = 'people'

  include Peoplefinder::Concerns::Completion
  include Peoplefinder::Concerns::Notifications
  include Peoplefinder::Concerns::WorkDays
  include Peoplefinder::Concerns::ExposeMandatoryFields

  extend FriendlyId
  friendly_id :slug_source, use: :slugged

  def slug_source
    email.present? ? email.split(/@/).first : name
  end

  include Peoplefinder::Concerns::Searchable

  def as_indexed_json(_options = {})
    as_json(
      only: [:tags, :description, :location_in_building, :building, :city],
      methods: [:name, :role_and_group, :community_name]
    )
  end

  def self.fuzzy_search(query)
    search(
      size: 100,
      query: {
        fuzzy_like_this: {
          fields: [
            :name, :tags, :description, :location_in_building, :building,
            :city, :role_and_group, :community_name
          ],
          like_text: query, prefix_length: 3, ignore_tf: true
        }
      }
    )
  end

  has_paper_trail class_name: 'Peoplefinder::Version',
                  ignore: [:updated_at, :created_at, :id, :slug, :login_count, :last_login_at]

  def changes_for_paper_trail
    super.tap { |changes|
      changes['image'].map! { |img| img.url && File.basename(img.url) } if changes.key?('image')
    }
  end

  include Peoplefinder::Concerns::Sanitizable
  sanitize_fields :given_name, :surname, :email
  before_save :sanitize_tags

  mount_uploader :image, Peoplefinder::ImageUploader
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  validates :given_name, presence: true, on: :update
  validates :surname, presence: true
  validates :email,
    presence: true, uniqueness: { case_sensitive: false }, 'peoplefinder/email' => true

  has_many :memberships, -> { includes(:group).order('groups.name') }, dependent: :destroy
  has_many :groups, through: :memberships
  belongs_to :community

  accepts_nested_attributes_for :memberships,
    allow_destroy: true,
    reject_if: proc { |membership| membership['group_id'].blank? }

  default_scope { order(surname: :asc, given_name: :asc) }

  def self.namesakes(person)
    where(surname: person.surname, given_name: person.given_name).where.not(id: person.id)
  end

  def self.tag_list
    where('tags is not null').pluck(:tags).flatten.join(',').split(',').uniq.sort.join(',')
  end

  def self.all_in_groups(group_ids)
    query = <<-SQL
      SELECT DISTINCT p.*,
        string_agg(CASE role WHEN '' THEN NULL ELSE role END, ', ' ORDER BY role) AS role_names
      FROM memberships m, people p
      WHERE m.person_id = p.id AND group_id in (?)
      GROUP BY p.id
      ORDER BY surname ASC, given_name ASC;
    SQL
    find_by_sql([query, group_ids])
  end

  def to_s
    name
  end

  def role_and_group
    memberships.join('; ')
  end

  def path(hint_group = nil)
    group_path(hint_group) + [self]
  end

  def phone
    [primary_phone_number, secondary_phone_number].find(&:present?)
  end

  delegate :name, to: :community, prefix: true, allow_nil: true

  include Peoplefinder::Concerns::ConcatenatedFields
  concatenated_field :location, :location_in_building, :building, :city, join_with: ', '
  concatenated_field :name, :given_name, :surname, join_with: ' '

private

  def group_path(hint_group)
    return [] if groups.empty?
    paths = groups.map(&:path)
    paths.find { |a| a.include?(hint_group) } || paths.first
  end

  def sanitize_tags
    return unless tags
    self.tags = tags.split(',').map { |t| t.strip.capitalize }.sort.join(',')
  end
end
