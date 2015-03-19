class NormalizeEmailCase < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE people
      SET email = lower(email);

      UPDATE tokens
      SET user_email = lower(user_email);

      UPDATE information_requests
      SET sender_email = lower(sender_email);

      UPDATE reported_profiles
      SET recipient_email = lower(recipient_email);
    SQL
  end
end
