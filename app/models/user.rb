class User < ActiveRecord::Base
  has_many :tokens

  belongs_to :manager, class_name: 'User'

  has_many :managees, foreign_key: :manager_id, class_name: 'User'
  has_many :reviews_received, foreign_key: :subject_id, class_name: 'Review'

  has_many :submissions, foreign_key: 'author_email', primary_key: 'email'
  has_many :acceptances, foreign_key: 'author_email', primary_key: 'email'

  default_scope { order(:name) }

  def to_s
    [name, email].reject(&:blank?).first
  end
end
