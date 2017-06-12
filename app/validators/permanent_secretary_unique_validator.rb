class PermanentSecretaryUniqueValidator < ActiveModel::Validator

  def validate(record)
    @record = record
    if perm_sec? && perm_sec_exists?
      record.errors[:leader] << perm_sec_unique_message
    end
  end

  private

  def scope_t
    [:errors, :validators, :permanent_secretary_unique_validator]
  end

  def perm_sec_unique_message
    I18n.t(
      :leader,
      scope: scope_t
    )
  end

  def perm_sec?
    @record.leader && @record.group_id == Group.department.id
  end

  def perm_sec_exists?
    current_perm_sec.present? &&
      current_perm_sec.id != @record.id
  end

  def current_perm_sec
    Membership.where(group_id: Group.department.id).where(leader: true).limit(1).first
  end
end
