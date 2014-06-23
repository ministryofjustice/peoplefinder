class AddImageToPeople < ActiveRecord::Migration
  def change
    add_column :people, :image, :string
  end
end
