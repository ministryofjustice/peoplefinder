class AddProfilePhotoIdToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :profile_photo_id, :integer
  end
end
