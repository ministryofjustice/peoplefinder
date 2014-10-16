class ReviewPeriod < ActiveRecord::Base
  extend SingleForwardable

  def_single_delegator :singleton_record, :closed?

  def self.open?
    !closed?
  end

  def self.closes_at=(datetime)
    singleton_record.update(closes_at: datetime)
  end

  def self.singleton_record
    first || new
  end

  def self.send_introductions
    return if closed?
    User.participants.each do |user|
      Introduction.new(user).send
    end
  end

  def self.send_closure_notifications
    return if open?
    User.participants.each do |user|
      ClosureNotification.new(user).send
    end
  end

  def closed?
    closes_at.nil? || closes_at < Time.now
  end
end
