class AddPgTrgmSearchIndexes < ActiveRecord::Migration[8.1]
  def up
    enable_extension "pg_trgm"

    execute "CREATE INDEX index_people_on_given_name_trgm ON people USING gin (lower(given_name) gin_trgm_ops)"
    execute "CREATE INDEX index_people_on_surname_trgm ON people USING gin (lower(surname) gin_trgm_ops)"
    execute "CREATE INDEX index_people_on_current_project_trgm ON people USING gin (lower(current_project) gin_trgm_ops) WHERE current_project IS NOT NULL"
    execute "CREATE INDEX index_groups_on_name_trgm ON groups USING gin (lower(name) gin_trgm_ops)"
  end

  def down
    remove_index :people, name: "index_people_on_given_name_trgm"
    remove_index :people, name: "index_people_on_surname_trgm"
    remove_index :people, name: "index_people_on_current_project_trgm"
    remove_index :groups, name: "index_groups_on_name_trgm"
    disable_extension "pg_trgm"
  end
end
