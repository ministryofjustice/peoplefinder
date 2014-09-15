class AddRatingsToReviews < ActiveRecord::Migration
  def change
    remove_column :reviews, :rating, :string
    remove_column :reviews, :achievements, :text
    remove_column :reviews, :improvements, :text

    (1 .. 11).each do |i|
      add_column :reviews, "rating_#{i}", :integer
    end

    add_column :reviews, :leadership_comments, :text
    add_column :reviews, :how_we_work_comments, :text
  end
end
