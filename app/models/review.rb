class Review < ActiveRecord::Base
  STATUSES = [:no_response, :rejected, :accepted, :started, :submitted]

  belongs_to :review_period
  belongs_to :subject, class_name: 'User'
  belongs_to :author, class_name: 'User', foreign_key: 'author_email',
                      primary_key: 'email'

  has_many :tokens

  validates :review_period, presence: true
  validates :subject, presence: true
  validates :author_email, presence: true
  validates :author_name, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :submitted, -> { where(status: :submitted) }

  # Convert status to a symbol safely
  STATUS_LOOKUP = Hash[STATUSES.map(&:to_s).zip(STATUSES)]
  def status
    STATUS_LOOKUP[super.to_s]
  end

  before_validation(on: :create) do
    self.review_period = ReviewPeriod.current
  end
end
