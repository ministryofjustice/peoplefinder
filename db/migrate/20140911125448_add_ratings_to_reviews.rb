class AddRatingsToReviews < ActiveRecord::Migration
  def change
    remove_column :reviews, :rating, :string
    remove_column :reviews, :achievements, :text
    remove_column :reviews, :improvements, :text

    Review::RATING_FIELDS.each do |rating|
      add_column :reviews, rating, :integer
    end

    add_column :reviews, :leadership_comments, :text
    add_column :reviews, :how_we_work_comments, :text
  end
end
