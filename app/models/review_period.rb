class ReviewPeriod < ActiveRecord::Base
  validate on: :create do
    if ReviewPeriod.current
      errors.add(:base, 'There is already a current review period')
    end
  end

  def self.current
    ReviewPeriod.where(ended_at: nil).first
  end

  def close!
    update_attributes(ended_at: Time.now)
  end
end
