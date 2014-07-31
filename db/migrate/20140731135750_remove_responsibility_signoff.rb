class RemoveResponsibilitySignoff < ActiveRecord::Migration
  def change
    remove_column 'agreements', 'responsibilities_signed_off_by_staff_member'
    remove_column 'agreements', 'responsibilities_signed_off_by_manager'
  end
end
