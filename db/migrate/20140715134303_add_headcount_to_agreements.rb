class AddHeadcountToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :headcount_responsibilities, :hstore
  end
end
