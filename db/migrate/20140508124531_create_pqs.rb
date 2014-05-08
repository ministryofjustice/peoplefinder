class CreatePqs < ActiveRecord::Migration
  def change
    create_table :pqs do |t|
      t.integer :PIN
      t.integer :HouseID
      t.integer :RaisingMemberID
      t.datetime :DateRaised
      t.datetime :ResponseDue
      t.string :Question
      t.string :Answer

      t.timestamps
    end
  end
end
