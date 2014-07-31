class CreateAgreements < ActiveRecord::Migration
  def change
    create_table :agreements do |t|
      t.integer :manager_id
      t.integer :jobholder_id

      t.timestamps
    end

    add_index "agreements", ["manager_id", "jobholder_id"]
  end
end
