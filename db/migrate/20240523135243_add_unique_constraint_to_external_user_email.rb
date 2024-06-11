class AddUniqueConstraintToExternalUserEmail < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      CREATE UNIQUE INDEX index_external_users_on_lowercase_email
      ON external_users (lower(email));
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX index_external_users_on_lowercase_email;
    SQL
  end
end
