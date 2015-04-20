class AddProfilePhotoIdToPeople < ActiveRecord::Migration
  def change
    add_column :people, :profile_photo_id, :integer
  end
end
