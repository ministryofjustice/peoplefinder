class CleanUpUsers < ActiveRecord::Migration
  def change
    remove_column 'users', 'staff_number'
    remove_column 'users', 'grade'
    remove_column 'users', 'organisation'
    remove_column 'users', 'password_digest'
    remove_column 'users', 'password_reset_token'
  end
end
