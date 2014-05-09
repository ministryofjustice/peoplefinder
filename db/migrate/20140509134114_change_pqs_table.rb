class ChangePqsTable < ActiveRecord::Migration
  def change
  	change_table :pqs do |t|
	  t.rename :PIN, :pin
	  t.rename :HouseID, :house_id
	  t.rename :RaisingMemberID, :raising_member_id
	  t.rename :DateRaised, :date_raised
	  t.rename :ResponseDue, :response_due
	  t.rename :Question, :question
	  t.rename :Answer, :answer
	end
  end
end
