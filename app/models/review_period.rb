class ReviewPeriod < ActiveRecord::Base
  validate :unique_current_review_period, on: :create

  def self.current
    ReviewPeriod.where(ended_at: nil).first
  end

  def close!
    update_attributes(ended_at: Time.now)
  end

private

  def unique_current_review_period
    if ReviewPeriod.current
      errors.add(:base, 'There is already a current review period')
    end
  end
end
