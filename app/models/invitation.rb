class Invitation < Review
  include TranslatedErrors

  default_scope { where(status: [:no_response, :declined]) }
  validates :reason_declined, length: { in: 0..300 }, allow_nil: true

  def declined?
    status == :declined
  end

  def change_state(state, reason = nil)
    self.attributes = { status: state, reason_declined: reason }
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
      add_translated_error :status, :invalid_state, state: status
      false
    end
  end

  def valid_reason?
    if declined? && reason_declined.blank?
      add_translated_error :reason_declined, :mandatory_reason
      false
    else
      true
    end
  end

protected

  def communicate_change
    if declined?
      token = subject.tokens.create!
      ReviewMailer.request_declined(self, token).deliver
    end
  end
end
