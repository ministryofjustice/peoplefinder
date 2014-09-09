class Review < ActiveRecord::Base
  include TranslatedErrors
  extend SymbolField

  STATUSES = [:no_response, :declined, :accepted, :started, :submitted]

  belongs_to :subject, -> { where participant: true }, class_name: 'User'
  belongs_to :author, class_name: 'User', foreign_key: 'author_email',
                      primary_key: 'email'

  has_many :tokens

  validates :subject, presence: true
  validates :author_email, presence: true
  validates :author_email, uniqueness: { scope: :subject_id,
                                         message: 'has already been invited' }
  validates :author_name, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validate :subject_is_participant

  scope :submitted, -> { where(status: :submitted) }

  after_initialize :prefill_invitation_message

  symbol_field :status, STATUSES

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
