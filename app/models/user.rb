class User < ActiveRecord::Base
  include EmailNormalization

  has_many :tokens,
    dependent: :destroy
  has_many :direct_reports,
    class_name: :User,
    foreign_key: :manager_id
  has_many :reviews,
    foreign_key: :subject_id,
    dependent: :destroy
  has_many :replies,
    class_name: :Review,
    primary_key: :email,
    foreign_key: :author_email
  has_many :invitations,
    primary_key: :email,
    foreign_key: :author_email
  has_many :identities

  belongs_to :manager, class_name: 'User'

  validates :email,
    presence: true,
    format: /\A.+@.+\z/,
    uniqueness: true

  default_scope { order(:name) }

  before_destroy :orphan_direct_reports

  def self.participants
    where(participant: true)
  end

  def self.with_feedback_not_received
    joins(:reviews).merge(Review.open)
  end

  def self.with_identity
    joins(:identities)
  end

  def self.admin
    where(administrator: true)
  end

  def email=(e)
    super normalize_email(e)
  end

  def to_s
    [name, email].reject(&:blank?).first
  end

  def manages?
    direct_reports.any?
  end

  def managed?
    manager.present?
  end

  def reviewer?
    replies.any?
  end

  def review_completion
    ReviewCompletion.new(reviews)
  end

  def administrator?
    administrator
  end

  def available_managers
    self.class.participants.where(self.class.arel_table[:id].not_eq(id))
  end

  def self.find_admin_by_email(email)
    admin.with_identity.where(email: email).first
  end

  def primary_identity
    identities.first
  end

private

  def orphan_direct_reports
    direct_reports.each do |dr|
      dr.update(manager: nil)
    end
  end
end
