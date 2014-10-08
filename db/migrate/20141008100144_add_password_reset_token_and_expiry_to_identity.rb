class AddPasswordResetTokenAndExpiryToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :password_reset_token, :string
    add_column :identities, :password_reset_expires_at, :datetime
  end
end
