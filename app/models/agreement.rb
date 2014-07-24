class Agreement < ActiveRecord::Base
  belongs_to :manager, class_name: 'User'
  belongs_to :jobholder, class_name: 'User'
  has_many :objectives

  accepts_nested_attributes_for :objectives, allow_destroy: true

  has_many :budgetary_responsibilities

  accepts_nested_attributes_for :budgetary_responsibilities, allow_destroy: true

  validates :manager, presence: true
  validates :jobholder, presence: true
  validates :manager_email, presence: true

  delegate :email, to: :manager, prefix: true, allow_nil: true
  delegate :email, to: :jobholder, prefix: true, allow_nil: true

  PAYBANDS = [
    :payband_1, :payband_a, :payband_b, :payband_c, :payband_d, :payband_e
  ]

  store_accessor :headcount_responsibilities, :number_of_staff,
    :staff_engagement_score, *PAYBANDS

  scope :editable_by, ->(user) {
    where(
      arel_table[:jobholder_id].eq(user.id).
      or(arel_table[:manager_id].eq(user.id))
    )
  }

  def manager_email=(email)
    self.manager = User.for_email(email) if email.present?
  end

  def jobholder_email=(email)
    self.jobholder = User.for_email(email) if email.present?
  end
end
