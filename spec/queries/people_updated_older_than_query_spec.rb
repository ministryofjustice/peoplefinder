require 'rails_helper'

describe PeopleUpdatedOlderThanQuery do

  describe '#call' do
    it 'generates the expected sql' do
      Timecop.freeze(Time.utc(2016, 11, 22, 4, 3, 6)) do
        expect(PeopleUpdatedOlderThanQuery.new(3.days.ago).call.to_sql).to match_sql expected_sql
      end
    end

    it 'returns an arel relation' do
      expect(PeopleUpdatedOlderThanQuery.new(2.days.ago).call).to be_an_instance_of(Person::ActiveRecord_Relation)
    end

    it 'returns expected records' do
      create :person, :with_random_dets
      p1 = create :person, :with_random_dets, updated_at: 5.days.ago
      p2 = create :person, :with_random_dets, updated_at: 7.days.ago
      expect(PeopleUpdatedOlderThanQuery.new(2.days.ago).call).to match_array([p1, p2])
    end

    def expected_sql
      %q{
        SELECT "people".*
        FROM "people"
        WHERE (updated_at < '2016-11-19 04:03:06.000000')
        ORDER BY "people"."surname" ASC, "people"."given_name" ASC
      }
    end
  end
end
