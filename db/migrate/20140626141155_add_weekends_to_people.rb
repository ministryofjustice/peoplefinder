class AddWeekendsToPeople < ActiveRecord::Migration
  def change
    add_column :people, :works_saturday, :boolean, default: false
    add_column :people, :works_sunday, :boolean, default: false
  end
end
