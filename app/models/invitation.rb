class Invitation < Reply
  default_scope { where(status: [:no_response, :declined]) }
  validates :reason_declined, length: { in: 0..300 }, allow_nil: true

  def declined?
    status == :declined
  end

  def change_state(state, reason = nil)
    self.attributes = { status: STATUS_LOOKUP[state], reason_declined: reason }
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
    if declined? && reason_declined.blank?
      errors.add(:reason_declined,
        I18n.translate('invitations.errors.mandatory_reason'))
      false
    else
      true
    end
  end

protected

  def communicate_change
    if declined?
      token = tokens.create!
      ReviewMailer.request_declined(self, token).deliver
    end
  end
end
