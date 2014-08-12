class Person < ActiveRecord::Base
  extend FriendlyId
  include Searchable
  include Completion

  DAYS_WORKED = [
    :works_monday,
    :works_tuesday,
    :works_wednesday,
    :works_thursday,
    :works_friday,
    :works_saturday,
    :works_sunday
  ]

  VALID_EMAIL_PATTERN = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/

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

  def hierarchy(hint_group = nil)
    if groups.empty?
      items = []
    elsif groups.length == 1 || hint_group.nil?
      items = groups.first.hierarchy
    else
      group = groups.find { |g| g.hierarchy.include?(hint_group) } ||
        groups.first
      items = group.hierarchy
    end
    items + [self]
  end

  def assignable_groups
    Group.where.not(id: memberships.pluck(:group_id))
  end

  def valid_email?(email = nil)
    email ||= self.email
    email.present? && email.match(VALID_EMAIL_PATTERN)
  end

  def send_create_email!(current_user)
    if should_send_email_notification?(email, current_user)
      UserUpdateMailer.new_profile_email(self, current_user.email).deliver
    end
  end

  def send_update_email!(current_user, old_email)
    if email == old_email
      notify_updates_to_unchanged_email_address current_user
    else
      notify_updates_to_changed_email_address current_user, old_email
    end
  end

  def notify_updates_to_unchanged_email_address(current_user)
    if should_send_email_notification?(email, current_user)
      UserUpdateMailer.updated_profile_email(
        self, current_user.email
      ).deliver
    end
  end

  def notify_updates_to_changed_email_address(current_user, old_email)
    if should_send_email_notification?(email, current_user)
      UserUpdateMailer.updated_address_to_email(
        self, current_user.email, old_email
      ).deliver
    end
    if should_send_email_notification?(old_email, current_user)
      UserUpdateMailer.updated_address_from_email(
        self, current_user.email, old_email
      ).deliver
    end
  end

  def send_destroy_email!(current_user)
    if should_send_email_notification?(email, current_user)
      UserUpdateMailer.deleted_profile_email(self, current_user.email).deliver
    end
  end

  def phone
    return primary_phone_number if primary_phone_number.present?
    return secondary_phone_number if secondary_phone_number.present?
  end

private

  def should_send_email_notification?(email, current_user)
    valid_email?(email) && current_user.email != email &&
      EmailAddress.new(email).valid_domain?
  end
end
