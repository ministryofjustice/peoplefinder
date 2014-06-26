class AddIndexOnSlugToPeople < ActiveRecord::Migration
  def change
    add_index "people", ["slug"], unique: true
  end
end
