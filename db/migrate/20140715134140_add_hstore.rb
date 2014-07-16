class AddHstore < ActiveRecord::Migration
  def up
    execute 'CREATE EXTENSION hstore'
    enable_extension "hstore"
  end

  def down
    disable_extension "hstore"
    execute 'DROP EXTENSION hstore'
  end
end
