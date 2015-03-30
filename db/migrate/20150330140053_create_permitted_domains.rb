class CreatePermittedDomains < ActiveRecord::Migration
  def change
    create_table :permitted_domains do |t|
      t.string :domain
      t.timestamps
    end
  end
end
