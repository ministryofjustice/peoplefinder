class InformationRequest < ActiveRecord::Base
  belongs_to :recipient, class_name: 'Person', foreign_key: 'recipient_id'
  validates :recipient_id, presence: true
  validates :sender_email, presence: true
  validates :message, presence: true
end
