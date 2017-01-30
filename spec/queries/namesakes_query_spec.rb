require 'rails_helper'

describe NamesakesQuery do

  describe '#call' do

    let(:person) { build :person, given_name: 'Stephen', surname: 'Richards', email: 'stephen.richards@person.com' }

    it 'generates the expected sql' do
      expect(described_class.new(person).call.to_sql).to match_sql expected_sql
    end

    it 'returns an arel relation' do
      expect(described_class.new(person).call).to be_an_instance_of(Person::ActiveRecord_Relation)
    end

    it 'returns expected records' do
      %w( person.com person2.com person3.com person4.com ).each { |domain| create :permitted_domain, domain: domain }
      person.save!
      person2 = create(:person, given_name: 'Stephen', surname: 'Richards', email: 'stephen.richards@person2.com')
      person3 = create(:person, given_name: 'Stephen', surname: 'Richards', email: 'stephen.richards@person3.com')
      person4 = create(:person, given_name: 'Steve', surname: 'Richards', email: 'stephen.richards@person4.com')
      create(:person, given_name: 'Steve', surname: 'Richardson', email: 'stephen.richardson@person2.com')
      create(:person, given_name: 'Joan', surname: 'Mulholland', email: 'joan.nulholland@person2.com')
      create(:person, given_name: 'Stephen', surname: 'Mulholland', email: 'stephen.nulholland@person2.com')

      expect(described_class.new(person).call).to match_array([person2, person3, person4])
    end

    def expected_sql
      %q{
        SELECT "people".*
        FROM "people"
        WHERE ("people"."id" IS NOT NULL)
        AND (
          (LOWER(surname) = 'richards' AND LOWER(given_name) = 'stephen')
        OR
          REGEXP_REPLACE(SUBSTR(email, 0, position('@' in email)), '\W|\d', '', 'g') = 'stephenrichards')
        ORDER BY "people"."surname" ASC,
        "people"."given_name" ASC
      }
    end
  end
end
