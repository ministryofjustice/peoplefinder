class InitNewReviewPeriod < ActiveRecord::Migration
  def up
    add_column :reviews, :review_period_id, :integer

    execute("Update reviews set review_period_id = #{ ReviewPeriod.current.id }")
  end

  def down
    remove_column :reviews, :review_period_id
  end

  class ReviewPeriod < ActiveRecord::Base
    def self.current
      ReviewPeriod.where(ended_at: nil).first || ReviewPeriod.create
    end
  end
end