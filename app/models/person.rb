class Person < ActiveRecord::Base
  include Concerns::Completion
  include Concerns::WorkDays
  include Concerns::ExposeMandatoryFields
  belongs_to :profile_photo

  extend FriendlyId
  friendly_id :slug_source, use: :slugged

  def slug_source
    email.present? ? email.split(/@/).first : name
  end

  include Concerns::Searchable

  def as_indexed_json(_options = {})
    as_json(
      only: [:tags, :description, :location_in_building, :building, :city],
      methods: [:name, :role_and_group, :community_name]
    )
  end

  has_paper_trail class_name: 'Version',
                  ignore: [:updated_at, :created_at, :id, :slug, :login_count, :last_login_at]

  def changes_for_paper_trail
    super.tap { |changes|
      changes['image'].map! { |img| img.url && File.basename(img.url) } if changes.key?('image')
    }
  end

  include Concerns::Sanitizable
  sanitize_fields :given_name, :surname, strip: true
  sanitize_fields :email, strip: true, downcase: true

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_save :crop_profile_photo

  def crop_profile_photo
    profile_photo.crop crop_x, crop_y, crop_w, crop_h if crop_x.present?
  end

  mount_uploader :legacy_image, ImageUploader, mount_on: :image, mount_as: :image

  def profile_image
    if profile_photo
      profile_photo.image
    elsif attributes['image']
      legacy_image
    else
      nil
    end
  end

  validates :given_name, presence: true, on: :update
  validates :surname, presence: true
  validates :email,
    presence: true, uniqueness: { case_sensitive: false }, email: true
  validates :secondary_email, email: true, allow_blank: true

  has_many :memberships,
    -> { includes(:group).order('groups.name') },
    dependent: :destroy
  has_many :groups, through: :memberships
  belongs_to :community

  accepts_nested_attributes_for :memberships,
    allow_destroy: true,
    reject_if: proc { |membership| membership['group_id'].blank? }

  default_scope { order(surname: :asc, given_name: :asc) }

  def self.namesakes(person)
    where(surname: person.surname, given_name: person.given_name).where.not(id: person.id)
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

  def path
    groups.any? ? groups.first.path + [self] : [self]
  end

  def phone
    [primary_phone_number, secondary_phone_number].find(&:present?)
  end

  delegate :name, to: :community, prefix: true, allow_nil: true

  include Concerns::ConcatenatedFields
  concatenated_field :location, :location_in_building, :building, :city, join_with: ', '
  concatenated_field :name, :given_name, :surname, join_with: ' '

  def notify_of_change?(person_responsible)
    EmailAddress.new(email).valid_address? && person_responsible.try(:email) != email
  end
end
