class RenameNotificationsToInformationRequests < ActiveRecord::Migration
  def change
    rename_table :notifications, :information_requests
  end
end
