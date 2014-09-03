class User < ActiveRecord::Base
  has_many :tokens

  belongs_to :manager, class_name: 'User'

  has_many :managees, foreign_key: :manager_id, class_name: 'User'
  has_many :reviews, foreign_key: :subject_id
  has_many :replies, foreign_key: 'author_email', primary_key: 'email'
  has_many :submissions, foreign_key: 'author_email', primary_key: 'email'
  has_many :invitations, foreign_key: 'author_email', primary_key: 'email'
  validates :email, format: /.@./

  default_scope { order(:name) }

  def to_s
    [name, email].reject(&:blank?).first
  end
end
