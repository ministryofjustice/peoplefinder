# This migration comes from peoplefinder (originally 20150319122348)
class NormalizeEmailCase < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      UPDATE people
      SET email = lower(email);

      UPDATE tokens
      SET user_email = lower(user_email);
    SQL
  end
end
