class RemoveUnusedExtensions < ActiveRecord::Migration
  def change
    disable_extension "plpgsql"
    disable_extension "hstore"
  end
end
