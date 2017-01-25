require 'rails_helper'

describe PeopleNeverLoggedInQuery do

  describe '#call' do
    it 'generates the expected sql' do
      expect(described_class.new.call.to_sql).to match_sql expected_sql
    end

    it 'returns an arel relation' do
      expect(described_class.new.call).to be_an_instance_of(Person::ActiveRecord_Relation)
    end

    it 'returns only those people who have never logged in' do
      _p1 = create :person, :with_random_dets
      p2 = create :person, :with_random_dets, login_count: 0
      p3 = create :person, :with_random_dets, login_count: 0
      _p4 = create :person, :with_random_dets

      expect(described_class.new.call).to match_array([p2, p3])
    end

    def expected_sql
      '
        SELECT "people".*
        FROM "people"
        WHERE "people"."login_count" = 0
        ORDER BY "people"."surname" ASC, "people"."given_name" ASC
      '
    end
  end
end
