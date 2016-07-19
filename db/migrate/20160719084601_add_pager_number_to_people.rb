class AddPagerNumberToPeople < ActiveRecord::Migration
  def change
    add_column :people, :pager_number, :text
  end
end
