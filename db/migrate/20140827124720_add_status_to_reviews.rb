class AddStatusToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :status, :text
  end
end