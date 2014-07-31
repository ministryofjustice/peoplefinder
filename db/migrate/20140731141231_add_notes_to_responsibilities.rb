class AddNotesToResponsibilities < ActiveRecord::Migration
  def change
    add_column "agreements", "notes", :text
  end
end
