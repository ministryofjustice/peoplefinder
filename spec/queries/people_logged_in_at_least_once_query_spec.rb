require 'rails_helper'

describe PeopleLoggedInAtLeastOnceQuery do

  describe '#call' do
    it 'generates the expected sql' do
      expect(described_class.new.call.to_sql).to match_sql expected_sql
    end

    it 'returns an arel relation' do
      expect(described_class.new.call).to be_an_instance_of(Person::ActiveRecord_Relation)
    end

    it 'returns only those people who have logged in' do
      p1 = create :person, :with_random_dets
      _p2 = create :person, :with_random_dets, login_count: 0
      _p3 = create :person, :with_random_dets, login_count: 0
      p4 = create :person, :with_random_dets

      expect(described_class.new.call).to match_array([p1, p4])
    end

    def expected_sql
      '
        SELECT "people".*
        FROM "people"
        WHERE (login_count > 0)
        ORDER BY "people"."surname" ASC, "people"."given_name" ASC
      '
    end
  end
end
