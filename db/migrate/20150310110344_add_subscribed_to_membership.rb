# This migration comes from peoplefinder (originally 20150304110649)
class AddSubscribedToMembership < ActiveRecord::Migration[4.2]
  def change
    add_column :memberships, :subscribed, :boolean, default: true, null: false
  end
end
