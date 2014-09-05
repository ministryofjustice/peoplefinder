class AddInvitationMessageToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :invitation_message, :text, null: false
  end
end
