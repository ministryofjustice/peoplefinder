class CreateReviewPeriods < ActiveRecord::Migration
  def change
    create_table :review_periods do |t|
      t.datetime :ended_at
      t.timestamps
    end
  end
end
