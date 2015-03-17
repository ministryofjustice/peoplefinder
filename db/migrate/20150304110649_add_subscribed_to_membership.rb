class AddSubscribedToMembership < ActiveRecord::Migration
  def change
    add_column :memberships, :subscribed, :boolean, default: true, null: false
  end
end
