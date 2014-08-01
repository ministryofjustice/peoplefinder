class Agreement < ActiveRecord::Base
  belongs_to :manager, class_name: 'User'
  belongs_to :staff_member, class_name: 'User'

  has_many :objectives,
    after_add: :objectives_have_changed,
    after_remove: :objectives_have_changed
  accepts_nested_attributes_for :objectives,
    allow_destroy: true,
    reject_if: :all_blank

  has_many :budgetary_responsibilities
  accepts_nested_attributes_for :budgetary_responsibilities,
    allow_destroy: true,
    reject_if: :all_blank

  before_save :reset_sign_off_if_changed
  after_save :unset_change_flags

  validates :manager, presence: true
  validates :staff_member, presence: true

  delegate :email, to: :manager, prefix: true, allow_nil: true
  delegate :email, to: :staff_member, prefix: true, allow_nil: true

  PAYBANDS = [
    :fast_stream_headcount,
    :payband_1_headcount,
    :payband_a_headcount,
    :payband_b_headcount,
    :payband_c_headcount,
    :payband_d_headcount,
    :payband_e_headcount
  ]

  store_accessor :headcount_responsibilities, :staff_engagement_score, *PAYBANDS

  scope :editable_by, lambda { |user|
    where(
      arel_table[:staff_member_id].eq(user.id).
      or(arel_table[:manager_id].eq(user.id))
    )
  }

private

  def reset_sign_off_if_changed
    if objectives_changed?
      reset_objectives_sign_off_unless_expressly_set
    end

    true
  end

  def reset_objectives_sign_off_unless_expressly_set
    unless objectives_signed_off_by_manager_changed?
      self.objectives_signed_off_by_manager = false
    end

    unless objectives_signed_off_by_staff_member_changed?
      self.objectives_signed_off_by_staff_member = false
    end
  end

  def objectives_have_changed(_)
    @objectives_have_changed = true
  end

  def unset_change_flags
    @objectives_have_changed = false
    true
  end

  def objectives_changed?
    @objectives_have_changed || objectives.any?(&:changed?)
  end
end
