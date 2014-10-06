class ReviewPeriod
  include Singleton

  def open?
    !closed?
  end

  def closed?
    Setting[:review_period] == 'closed'
  end

  def send_introductions
    return unless open?
    User.participants.each do |user|
      Introduction.new(user).send
    end
  end

  def send_closure_notifications
    return if open?
    User.participants.each do |participant|
      UserMailer.
        closure_notification(participant, participant.tokens.create).
        deliver
    end
  end
end
