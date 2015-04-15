class AdditionalEmail < ActiveRecord::Migration
  def change
    add_column 'people', 'secondary_email', :text
  end
end
