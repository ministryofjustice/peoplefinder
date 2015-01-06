class AddGinIndexToSearchIndexDocument < ActiveRecord::Migration
  def change
    add_index :search_index, :document, using: :gin
  end
end
