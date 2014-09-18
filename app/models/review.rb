class Review < ActiveRecord::Base
  include TranslatedErrors
  extend SymbolField

  STATUSES = %i[ no_response declined accepted started submitted ]
  REMINDABLE_STATUSES = %i[ no_response accepted started ]
  RELATIONSHIPS = %i[ peer line_manager direct_report supplier customer ]

  SECTION_1_RATING_FIELDS = (1 .. 4).map { |i| :"rating_#{i}" }
  SECTION_2_RATING_FIELDS = (5 .. 11).map { |i| :"rating_#{i}" }
  RATING_FIELDS = SECTION_1_RATING_FIELDS + SECTION_2_RATING_FIELDS

  belongs_to :subject, -> { where participant: true }, class_name: 'User'
  belongs_to :author, class_name: 'User', foreign_key: 'author_email',
                      primary_key: 'email'

  has_many :tokens

  validates :subject, presence: true
  validates :author_email, presence: true
  validates :author_email, uniqueness: { scope: :subject_id }
  validates :author_name, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :relationship, presence: true
  validates :relationship,
    inclusion: { in: RELATIONSHIPS },
    if: ->(a) { a.relationship.present? }
  validate :subject_is_participant

  scope :submitted, -> { where(status: :submitted) }

  after_initialize :prefill_invitation_message

  symbol_field :status, STATUSES
  symbol_field :relationship, RELATIONSHIPS

  delegate :name, to: :subject, prefix: true

  def self.for_user(user)
    where(
      arel_table[:subject_id].eq(user.id).
      or(arel_table[:author_email].eq(user.email))
    )
  end

  def remindable?
    REMINDABLE_STATUSES.include?(status)
  end

  def complete?
    status == :submitted
  end

  def author_name
    (author && author.name) || super
  end

private

  def prefill_invitation_message
    self.invitation_message ||= I18n.t('reviews.default_invitation_message')
  end

  def subject_is_participant
    if subject && !subject.participant
      add_translated_error :subject, :subject_must_be_participant
    end
  end
end
