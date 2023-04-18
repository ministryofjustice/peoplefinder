class AddSwapEmailDisplayToPeople < ActiveRecord::Migration[6.1]
  def change
    add_column :people, :swap_email_display, :boolean
  end
end
