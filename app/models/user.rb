class User < ActiveRecord::Base
  has_many :tokens

  belongs_to :manager, class_name: 'User'

  has_many :direct_reports, foreign_key: :manager_id, class_name: 'User'
  has_many :reviews, foreign_key: :subject_id
  has_many :replies, foreign_key: 'author_email', primary_key: 'email'
  has_many :submissions, foreign_key: 'author_email', primary_key: 'email'
  has_many :invitations, foreign_key: 'author_email', primary_key: 'email'
  validates :email, format: /.@./

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
end
