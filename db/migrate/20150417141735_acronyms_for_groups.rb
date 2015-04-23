class AcronymsForGroups < ActiveRecord::Migration
  def change
    add_column 'groups', 'acronym', :text
  end
end
