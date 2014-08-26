class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :subject
      t.text :author_name
      t.text :author_email
      t.text :relationship
    end
  end
end
