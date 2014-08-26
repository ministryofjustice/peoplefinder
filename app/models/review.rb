class Review < ActiveRecord::Base
  belongs_to :subject, class_name: 'User'

  validates :subject, presence: true
  validates :author_email, presence: true
  validates :author_name, presence: true
end
