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

  belongs_to :manager, class_name: 'User'

  validates :email, presence: true, format: /.@./, uniqueness: true

  default_scope { order(:name) }

  scope :participants, -> { where(participant: true) }

  before_destroy :orphan_direct_reports

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

  def review_completion
    ReviewCompletion.new(reviews)
  end

  def administrator?
    administrator
  end

private

  def orphan_direct_reports
    direct_reports.each do |dr|
      dr.update(manager: nil)
    end
  end
end
