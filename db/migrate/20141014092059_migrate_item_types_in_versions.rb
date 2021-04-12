# This migration comes from peoplefinder (originally 20141010090624)
class MigrateItemTypesInVersions < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      UPDATE versions
      SET item_type = 'Peoplefinder::' || item_type
      WHERE item_type NOT LIKE 'Peoplefinder::%';
    SQL
  end

  def down
    execute <<-SQL
      UPDATE versions
      SET item_type = split_part(item_type, '::', 2)
      WHERE split_part(item_type, '::', 1) = 'Peoplefinder';
    SQL
  end
end
