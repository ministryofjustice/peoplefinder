class AddSubmissionFieldsToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :rating, :string
    add_column :reviews, :achievements, :text
    add_column :reviews, :improvements, :text
  end
end