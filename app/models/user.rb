class User < ActiveRecord::Base
  has_many :tokens
  belongs_to :manager, class_name: 'User'
  has_many :managees, foreign_key: :manager_id, class_name: 'User'
  has_many :reviews_received, foreign_key: :subject_id, class_name: 'Review'

  def to_s
    [name, email].reject(&:blank?).first
  end
end
