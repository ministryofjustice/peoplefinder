class User < ActiveRecord::Base
  has_many :tokens
  has_many :direct_reports,
    class_name: :User,
    foreign_key: :manager_id
  has_many :reviews,
    foreign_key: :subject_id
  has_many :replies,
    class_name: :Review,
    primary_key: :email,
    foreign_key: :author_email
  has_many :invitations,
    primary_key: :email,
    foreign_key: :author_email

  belongs_to :manager, class_name: 'User'

  validates :email, format: /.@./, uniqueness: true

  default_scope { order(:name) }

  scope :participants, -> { where(participant: true) }

  def to_s
    [name, email].reject(&:blank?).first
  end

  def manages?
    direct_reports.any?
  end

  def managed?
    manager.present?
  end

  def review_completion
    ReviewCompletion.new(reviews)
  end
end
