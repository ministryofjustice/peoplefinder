class IndexOnAuthorEmailReviews < ActiveRecord::Migration
  def change
    add_index :reviews, :author_email
  end
end
