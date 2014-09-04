class Review < ActiveRecord::Base
  STATUSES = [:no_response, :rejected, :accepted, :started, :submitted]

  belongs_to :subject, -> { where participant: true }, class_name: 'User'
  belongs_to :author, class_name: 'User', foreign_key: 'author_email',
                      primary_key: 'email'

  has_many :tokens

  validates :subject, presence: true
  validate :subject_is_participant
  validates :author_email, presence: true
  validates :author_name, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :submitted, -> { where(status: :submitted) }

  # Convert status to a symbol safely
  STATUS_LOOKUP = Hash[STATUSES.map(&:to_s).zip(STATUSES)]
  def status
    STATUS_LOOKUP[super.to_s]
  end

private

  def subject_is_participant
    if subject && !subject.participant
      errors.add(:subject, 'must be a participant')
    end
  end
end
