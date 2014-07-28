class Person < ActiveRecord::Base
  extend FriendlyId
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  DAYS_WORKED = [
    :works_monday,
    :works_tuesday,
    :works_wednesday,
    :works_thursday,
    :works_friday,
    :works_saturday,
    :works_sunday,
  ]

  index_name [Rails.env, model_name.collection.gsub(/\//, '-')].join('_')

  has_paper_trail ignore: [:updated_at, :created_at, :id, :slug]
  mount_uploader :image, ImageUploader

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  validates_presence_of :surname
  has_many :memberships, -> { includes(:group).order("groups.name")  },
    dependent: :destroy
  has_many :groups, through: :memberships

  accepts_nested_attributes_for :memberships, allow_destroy: true,
    reject_if: proc { |membership| membership['group_id'].blank? }

  default_scope { order(surname: :asc, given_name: :asc) }

  friendly_id :slug_source, use: :slugged

  def self.delete_indexes
    self.__elasticsearch__.delete_index! index: Person.index_name
  end

  def self.fuzzy_search(query)
    Person.search({
      size: 100,
      query: {
        fuzzy_like_this: {
          fields: [:name, :description, :location, :role_and_group],
          like_text: query,
          prefix_length: 3,
          ignore_tf: true
        }
      }
    })
  end

  def name
    [given_name, surname].compact.join(' ').strip
  end

  def to_s
    name
  end

  def completion_score
    completed = [
      :given_name,
      :surname,
      :email,
      :phone,
      :mobile,
      :location,
      :description,
      :groups
    ].map { |f| self.send(f).present? }
    (100 * completed.select { |f| f }.length) / completed.length
  end

  def profile_completed?
    completion_score == 100
  end

  def slug_source
    if email.present?
      email.split(/@/).first
    else
      name
    end
  end

  def as_indexed_json(options={})
    self.as_json(
      only: [:description, :location],
      methods: [:name, :role_and_group]
    )
  end

  def role_and_group
    memberships.map{ |m| [m.group_name, m.role].join(', ') }.join("; ")
  end

  def hierarchy(hint_group = nil)
    if groups.empty?
      items = []
    elsif groups.length == 1 || hint_group.nil?
      items = groups.first.hierarchy
    else
      group = groups.find { |g| g.hierarchy.include?(hint_group) } || groups.first
      items = group.hierarchy
    end
    items << self
  end

  def assignable_groups
    Group.where.not(id: memberships.pluck(:group_id))
  end
end
