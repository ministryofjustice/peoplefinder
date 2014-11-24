class DeclineNotification
  def initialize(invitation)
    @invitation = invitation
  end

  def send
    token = @invitation.subject.tokens.create!
    ReviewMailer.request_declined(@invitation, token).deliver
  end
end
