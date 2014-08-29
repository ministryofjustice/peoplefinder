class Review < ActiveRecord::Base
  STATUSES = %w[ no_response accepted rejected started completed ]

  belongs_to :subject, class_name: 'User'
  belongs_to :author, class_name: 'User', foreign_key: 'author_email',
                      primary_key: 'email'

  has_many :tokens

  validates :subject, presence: true
  validates :author_email, presence: true
  validates :author_name, presence: true
  validates :status, inclusion: { in: STATUSES }

  def send_feedback_request
    ReviewMailer.feedback_request(self, tokens.create).deliver
  end
end
