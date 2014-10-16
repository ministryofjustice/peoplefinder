class CreateReviewPeriod < ActiveRecord::Migration
  def change
    create_table :review_periods do |t|
      t.datetime :closes_at, null: false
    end
  end
end
