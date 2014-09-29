class ReportedProfile < ActiveRecord::Base
  belongs_to :notifier, class_name: 'Person', foreign_key: 'notifier_id'
  belongs_to :subject, class_name: 'Person', foreign_key: 'subject_id'

  validates :notifier_id, presence: true
  validates :subject_id, presence: true
  validates :recipient_email, presence: true
  validates :reason_for_reporting, presence: true

  REASONS = [
    'Duplicate profile',
    'Incorrect details',
    'This person has left the department'
  ]
end
