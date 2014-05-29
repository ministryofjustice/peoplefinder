class ActionOfficerAssignment < ActiveRecord::Migration
  def change
    create_table :assigment_ao_pq, id: false do |t|
          t.belongs_to :action_officer
          t.belongs_to :pq
    end
  end
end
