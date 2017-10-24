class AddPrimaryPhoneCountryCodeToPeople < ActiveRecord::Migration
  def change
    add_column :people, :primary_phone_country_code, :text
  end
end
