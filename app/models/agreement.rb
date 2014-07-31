class Agreement < ActiveRecord::Base
  belongs_to :manager, class_name: 'User'
  belongs_to :staff_member, class_name: 'User'

  has_many :objectives,
    after_add: :objectives_have_changed,
    after_remove: :objectives_have_changed
  accepts_nested_attributes_for :objectives,
    allow_destroy: true,
    reject_if: :all_blank

  has_many :budgetary_responsibilities,
    after_add: :budgetary_responsibilities_have_changed,
    after_remove: :budgetary_responsibilities_have_changed
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
    :payband_1, :payband_a, :payband_b, :payband_c, :payband_d, :payband_e
  ]

  store_accessor :headcount_responsibilities, :number_of_staff,
    :staff_engagement_score, *PAYBANDS

  scope :editable_by, ->(user) {
    where(
      arel_table[:staff_member_id].eq(user.id).
      or(arel_table[:manager_id].eq(user.id))
    )
  }

  RESPONSIBILITIES_FIELDS = [
    :headcount_responsibilities, :number_of_staff, :staff_engagement_score,
    *PAYBANDS
  ]

private
  def reset_sign_off_if_changed
    if has_responsibility_changes?
      reset_responsibilities_sign_off_unless_expressly_set
    end

    if has_objective_changes?
      reset_objectives_sign_off_unless_expressly_set
    end

    true
  end

  def reset_responsibilities_sign_off_unless_expressly_set
    unless responsibilities_signed_off_by_manager_changed?
      self.responsibilities_signed_off_by_manager = false
    end

    unless responsibilities_signed_off_by_staff_member_changed?
      self.responsibilities_signed_off_by_staff_member = false
    end
  end

  def reset_objectives_sign_off_unless_expressly_set
    unless objectives_signed_off_by_manager_changed?
      self.objectives_signed_off_by_manager = false
    end

    unless objectives_signed_off_by_staff_member_changed?
      self.objectives_signed_off_by_staff_member = false
    end
  end

  def budgetary_responsibilities_have_changed(agreement)
    @budgetary_responsibilities_have_changed = true
  end

  def objectives_have_changed(agreement)
    @objectives_have_changed = true
  end

  def unset_change_flags
    @budgetary_responsibilities_have_changed = false
    @objectives_have_changed = false

    true
  end

  def has_responsibility_changes?
    @budgetary_responsibilities_have_changed ||
      RESPONSIBILITIES_FIELDS.any? { |k| changed_attributes.has_key?(k) } ||
      budgetary_responsibilities.any?(&:changed?)
  end

  def has_objective_changes?
    @objectives_have_changed || objectives.any?(&:changed?)
  end
end
