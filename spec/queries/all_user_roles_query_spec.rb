require 'rails_helper'

describe AllUserRolesQuery do
  include PermittedDomainHelper

  let(:expected_attributes) { %w( id full_name address login_count last_login_at team_name team_role ancestors ) }

  let!(:person1) { create :person, given_name: 'Joel', surname: 'Sugarman', email: 'joel.sugarman@digital.justice.gov.uk' }
  let!(:person2) { create :person, given_name: 'John', surname: 'Smith', email: 'john.smith@digital.justice.gov.uk', login_count: 2, last_login_at: Time.new(2017, 05, 21, 2, 2, 2) }

  describe '#call' do
    subject { described_class.new.call }

    let(:expected_sql) do
      <<~SQL
         SELECT people.id,
         people.given_name || ' ' || people.surname AS full_name,
         people.location_in_building || ', ' || people.building || ', ' || people.city AS address,
         people.login_count,
         people.last_login_at,
         groups.name AS team_name,
         groups.ancestry || regexp_split_to_array(groups.ancestry,'/') AS ancestor_ids,
         CASE WHEN groups.ancestry_depth > 0 then
          (SELECT array_agg(name) AS names
          FROM (SELECT g2.name AS name
                FROM groups AS g2
                WHERE g2.id::text = ANY (regexp_split_to_array(groups.ancestry,'/')) ) as group_names
                )
          END AS ancestors,
          memberships.role AS team_role
          FROM "people"
          LEFT JOIN memberships ON memberships.person_id = people.id
          LEFT JOIN groups ON groups.id = memberships.group_id
          ORDER BY people.id, full_name
      SQL
    end

    it 'generates the expected sql' do
      expect(subject.to_sql).to match_sql expected_sql
    end

    it 'returns an arel relation' do
      is_expected.to be_an_instance_of(Person::ActiveRecord_Relation)
    end

    it 'returns expected columns' do
      expected_attributes.each do |attribute|
        expect(subject.first).to respond_to attribute.to_sym
      end
    end

    it 'returns expected records' do
      expect(described_class.new.call).to match_array([person1, person2])
    end
  end

  describe '#data' do
    subject { described_class.new.data }

    it 'returns an array of hashes' do
      is_expected.to be_an_instance_of(Array)
      expect(subject.first).to be_an_instance_of(Hash)
    end

    it 'returns expected attributes' do
      expected_attributes.each do |attribute|
        expect(subject.first).to have_key attribute.to_sym
      end
    end

    it 'returns expected records' do
      expect(described_class.new.call).to match_array([person1, person2])
    end
  end
end
