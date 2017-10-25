class AddContactInfoToPeople < ActiveRecord::Migration
  def change
    add_column :people, :country, :string
    add_column :people, :skype_name, :string
  end
end
