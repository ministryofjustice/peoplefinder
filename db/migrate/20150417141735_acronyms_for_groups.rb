class AcronymsForGroups < ActiveRecord::Migration[4.2]
  def change
    add_column 'groups', 'acronym', :text
  end
end
