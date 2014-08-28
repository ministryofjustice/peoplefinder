class AddRejectionReasonToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :rejection_reason, :text
  end
end