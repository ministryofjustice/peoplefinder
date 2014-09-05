class AddInvitationMessageToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :invitation_message, :text
    execute <<-SQL
      UPDATE reviews
      SET invitation_message = 'legacy record'
    SQL
    change_column_null :reviews, :invitation_message, false
  end
end
