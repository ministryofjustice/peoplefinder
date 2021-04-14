class AddPagerNumberToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :pager_number, :text
  end
end
