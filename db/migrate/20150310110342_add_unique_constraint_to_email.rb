# This migration comes from peoplefinder (originally 20150217105036)
class AddUniqueConstraintToEmail < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      CREATE UNIQUE INDEX index_people_on_lowercase_email
      ON people (lower(email));
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX index_people_on_lowercase_email;
    SQL
  end
end
