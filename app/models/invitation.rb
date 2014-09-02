class Invitation < Reply
  default_scope { where(status: [:no_response, :rejected]) }
  validates :rejection_reason, length: { in: 0..300 }, allow_nil: true

  def rejected?
    status == :rejected
  end

  def change_state(state, reason = nil)
    successful_update = false
    new_state = STATUS_LOOKUP[state]
    if STATUSES.include?(new_state)
      successful_update =  update_attributes(status: new_state,
                                             rejection_reason: reason)
      communicate_change
    else
      errors.add(:status, "#{new_state} is not a valid state")
    end
    successful_update
  end

protected

  def communicate_change
    if rejected?
      token = tokens.create!
      ReviewMailer.request_rejected(self, token).deliver
    end
  end
end
