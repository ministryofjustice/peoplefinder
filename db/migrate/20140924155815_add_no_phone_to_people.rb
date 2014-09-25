class AddNoPhoneToPeople < ActiveRecord::Migration
  def change
    add_column :people, :no_phone, :boolean, default: false
  end
end
