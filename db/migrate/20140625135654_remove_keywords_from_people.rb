class RemoveKeywordsFromPeople < ActiveRecord::Migration
  def change
    remove_column :people, :keywords, :string
  end
end