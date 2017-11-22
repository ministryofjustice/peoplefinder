class AddSecondaryPhoneCountryCodeToPeople < ActiveRecord::Migration
  def change
    add_column :people, :secondary_phone_country_code, :text
  end
end
