class Review < ActiveRecord::Base
  STATUSES = %w[ no_response rejected started submitted ]

  belongs_to :review_period
  belongs_to :subject, class_name: 'User'
  belongs_to :author, class_name: 'User', foreign_key: 'author_email',
                      primary_key: 'email'

  has_many :tokens

  validates :review_period, presence: true
  validates :subject, presence: true
  validates :author_email, presence: true
  validates :author_name, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :submitted, -> { where(status: 'submitted') }

  before_validation(on: :create) do
    self.review_period = ReviewPeriod.current
  end
end
