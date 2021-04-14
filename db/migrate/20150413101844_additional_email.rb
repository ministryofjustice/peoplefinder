class AdditionalEmail < ActiveRecord::Migration[4.2]
  def change
    add_column 'people', 'secondary_email', :text
  end
end
