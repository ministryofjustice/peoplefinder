class CreateProfilePhotos < ActiveRecord::Migration[4.2]
  def change
    create_table :profile_photos do |t|
      t.string :image
      t.timestamps
    end
  end
end
