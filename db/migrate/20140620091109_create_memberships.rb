class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.belongs_to :group, index: true
      t.belongs_to :person, index: true
      t.text :role
      t.timestamps
    end
  end
end
