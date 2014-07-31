class AddObjectivesToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :objectives, :hstore, array: true
  end
end
