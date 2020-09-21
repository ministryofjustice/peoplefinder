require 'rails_helper'

describe ReminderMailOlderThanQuery do

  describe '#call' do
    it 'generates the expected sql' do
      Timecop.freeze(Time.utc(2017, 1, 19, 12, 26, 1)) do
        expect(described_class.new(5.days.ago).call.to_sql).to match_sql expected_sql
      end
    end

    it 'returns an arel relation' do
      expect(described_class.new(3.days.ago).call).to be_an_instance_of(Person::ActiveRecord_Relation)
    end

    it 'returns expected records' do
      _p1 = create :person, :with_random_dets, last_reminder_email_at: 5.days.ago
      p2 = create :person, :with_random_dets, last_reminder_email_at: 7.days.ago
      expect(described_class.new(6.days.ago).call).to match_array([p2])
    end

    def expected_sql
      %q{
        SELECT "people".*
        FROM "people"
        WHERE (last_reminder_email_at IS NULL OR last_reminder_email_at < '2017-01-14 12:26:01')
        ORDER BY "people"."surname" ASC, "people"."given_name" ASC
      }
    end
  end
end
