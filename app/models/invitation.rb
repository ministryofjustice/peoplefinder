class Invitation < Review
  include TranslatedErrors

  def declined?
    status == :declined
  end

  def change_state(state, reason = nil)
    self.attributes = { status: state, reason_declined: reason }
    if valid?
      save.tap do
        communicate_change
      end
    else
      false
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
