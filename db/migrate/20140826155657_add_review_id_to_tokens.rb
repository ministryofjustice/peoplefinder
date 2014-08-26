class AddReviewIdToTokens < ActiveRecord::Migration
  def change
    add_column :tokens, :review_id, :integer
  end
end
