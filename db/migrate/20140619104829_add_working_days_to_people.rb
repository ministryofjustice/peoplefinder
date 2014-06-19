class AddWorkingDaysToPeople < ActiveRecord::Migration
  def change
    add_column :people, :works_monday, :boolean, :default => true
    add_column :people, :works_tuesday, :boolean, :default => true
    add_column :people, :works_wednesday, :boolean, :default => true
    add_column :people, :works_thursday, :boolean, :default => true
    add_column :people, :works_friday, :boolean, :default => true
  end
end
