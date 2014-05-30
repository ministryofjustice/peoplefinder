class CreateJoinTablePqAo < ActiveRecord::Migration
  def change
    create_join_table :pqs, :action_officers do |t|
      # t.index [:pq_id, :action_officer_id]
      # t.index [:action_officer_id, :pq_id]
    end
  end
end
