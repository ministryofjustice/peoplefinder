class SetDefaultReviewStatus < ActiveRecord::Migration
  def change
    execute <<-SQL
      UPDATE reviews
      SET status = 'no_response'
      WHERE status IS NULL
    SQL

    change_column 'reviews', 'status', :text, null: false,
      default: 'no_response'
  end
end
