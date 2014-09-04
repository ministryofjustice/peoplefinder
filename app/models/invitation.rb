class Invitation < Reply
  default_scope { where(status: [:no_response, :rejected]) }
  validates :rejection_reason, length: { in: 0..300 }, allow_nil: true

  def rejected?
    status == :rejected
  end

  def change_state(state, reason = nil)
    self.attributes = { status: STATUS_LOOKUP[state], rejection_reason: reason }
    if valid_status? && valid_reason?
      save.tap do
        communicate_change
      end
    else
      false
    end
  end

  def valid_status?
    if STATUSES.include?(status)
      true
    else
      errors.add(:status,
        I18n.translate('invitations.errors.invalid_state', state: status))
      false
    end
  end

  def valid_reason?
    if rejected? && rejection_reason.blank?
      errors.add(:rejection_reason,
        I18n.translate('invitations.errors.mandatory_reason'))
      false
    else
      true
    end
  end

protected

  def communicate_change
    if rejected?
      token = tokens.create!
      ReviewMailer.request_rejected(self, token).deliver
    end
  end
end
