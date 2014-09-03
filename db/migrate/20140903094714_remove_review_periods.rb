class RemoveReviewPeriods < ActiveRecord::Migration
  def change
    remove_column :reviews, :review_period_id, :integer
    drop_table :review_periods do |t|
      t.datetime :ended_at
      t.timestamps
    end
  end
end
