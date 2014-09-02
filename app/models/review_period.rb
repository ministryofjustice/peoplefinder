class ReviewPeriod < ActiveRecord::Base
  validate :unique_current_review_period, on: :create

  has_many :reviews
  has_many :users, through: :reviews, source: :subject

  def self.current
    ReviewPeriod.where(ended_at: nil).first
  end

  def close!
    update_attributes(ended_at: Time.now)
  end

  def send_closure_notifications
    return false if ReviewPeriod.current
    participants.each do |participant|
      UserMailer.
        closure_notification(participant, participant.tokens.create).
        deliver
    end
  end

  def participants
    users.map { |p| [p, p.manager].compact }.flatten.uniq
  end

private

  def unique_current_review_period
    if ReviewPeriod.current
      errors.add(:base, 'There is already a current review period')
    end
  end
end
