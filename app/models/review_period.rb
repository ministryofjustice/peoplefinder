class ReviewPeriod
  def initialize
  end

  def send_closure_notifications
    if ENV['REVIEW_PERIOD'] == 'CLOSED'
      participants.each do |participant|
        UserMailer.
          closure_notification(participant, participant.tokens.create).
          deliver
      end
    end
  end

  def participants
    Review.all.map { |r| [r.subject, r.subject.manager].compact }.flatten.uniq
  end
end
