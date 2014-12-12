class ReviewPeriod < ActiveRecord::Base
  extend SingleForwardable

  def_single_delegator :singleton_record, :closed?
  def_single_delegator :singleton_record, :closes_at

  def self.open?
    !closed?
  end

  def self.closes_at=(datetime)
    singleton_record.update(closes_at: datetime)
  end

  def self.seconds_left(now = Time.now)
    [(closes_at || now) - now, 0].max.to_i
  end

  def self.singleton_record
    first || new
  end

  def self.send_introductions
    return if closed?
    User.participants.each do |user|
      IntroductionNotification.new(user).notify
    end
  end

  def self.send_closure_notifications
    return if open?
    User.participants.each do |user|
      ClosureNotification.new(user).notify
    end
  end

  def self.default_closing_date(now = Time.now)
    date = now.utc.to_date + 30
    Time.new(date.year, date.month, date.day, 23, 59, 59, '+00:00')
  end

  def closed?
    closes_at.nil? || closes_at < Time.now
  end
end
