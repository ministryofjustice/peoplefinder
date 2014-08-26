class Review < ActiveRecord::Base
  belongs_to :subject, class_name: 'User'
  has_one :token

  validates :subject, presence: true
  validates :author_email, presence: true
  validates :author_name, presence: true

  after_create :generate_token

private

  def generate_token
    Token.create review: self
  end
end
