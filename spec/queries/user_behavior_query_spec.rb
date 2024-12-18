require "rails_helper"

describe UserBehaviorQuery, :versioning do
  include PermittedDomainHelper

  let(:expected_attributes) { %w[id full_name address login_count last_login_at team_name team_role ancestors updates_count].map(&:to_sym) }
  let(:moj) { create :department }
  let(:csg) { create(:group, name: "Corporate Services Group", parent: moj) }
  let(:ds) { create(:group, name: "Digital Services", parent: csg) }

  let!(:person_one) do
    person = create :person, given_name: "Joel", surname: "Sugarman", email: "joel.sugarman@digital.justice.gov.uk"
    person.memberships.destroy_all
    person.memberships.create!(group: ds, role: "Developer")
    person.memberships.create!(group: ds, role: "Tester")
    person.memberships.create!(group: csg, role: "Business Analyst")
    person
  end

  let!(:person_two) do
    person = create(:person, given_name: "John", surname: "Smith", email: "john.smith@digital.justice.gov.uk", login_count: 2, last_login_at: Time.new(2017, 0o5, 22, 2, 2, 2, "+00:00"))
    person.memberships.destroy_all
    person
  end

  let!(:person_three) do
    person = create :person, given_name: "Adrian", surname: "Smith", email: "adrian.smith@digital.justice.gov.uk", login_count: 3, last_login_at: Time.new(2016, 0o5, 21, 3, 3, 3, "+00:00")
    person.update! location_in_building: "10.51", building: "Fleet Street", city: "Vancouver"
    person.update! location_in_building: "10.52", building: "Fleet Street", city: "Vancouver"
    person.memberships.destroy_all
    person
  end

  describe "#call" do
    subject(:call) { described_class.new.call }

    let(:expected_sql) do
      <<~SQL
        SELECT people.id,
          people.given_name || ' ' || people.surname AS full_name,
          people.location_in_building || ', ' || people.building || ', ' || people.city AS address,
          people.email,
          people.secondary_email,
          people.primary_phone_number,
          people.secondary_phone_number,
          people.login_count,
          people.last_login_at,
          groups.name AS team_name,
          regexp_split_to_array(groups.ancestry,'\/') AS ancestors,
          memberships.role AS team_role,
          (
            SELECT count(v.id) AS updates_count
            FROM versions v
            WHERE v.item_id = people.id
              AND v.item_type = 'Person'
              AND v.event = 'update'
          ) AS updates_count
        FROM "people"
        LEFT JOIN memberships ON memberships.person_id = people.id
        LEFT JOIN groups ON groups.id = memberships.group_id
        ORDER BY people.id, full_name
      SQL
    end

    it "generates the expected sql" do
      expect(call.to_sql).to match_sql expected_sql
    end

    it "returns an arel relation" do
      expect(call).to be_an_instance_of(Person.const_get(:ActiveRecord_Relation))
    end

    it "returns expected columns" do
      expected_attributes.each do |attribute|
        expect(call.first).to respond_to attribute
      end
    end

    it "returns expected people records" do
      expect(call).to include(person_one, person_two, person_three)
    end

    it "returns person record for each persons membership" do
      counts = call.each_with_object(Hash.new(0)) { |rec, count| count[rec.full_name] += 1 }
      expect(counts[person_one.name]).to be 3
    end
  end

  describe "#data" do
    subject(:data) { described_class.new.data }

    let(:expected_collections) do
      [
        {
          id: person_one.id,
          full_name: person_one.name,
          address: nil,
          team_name: ds.name,
          team_role: "Developer",
          main_email_address: person_one.email,
          main_phone_number: nil,
          alternative_phone_number: nil,
          alternative_email_address: nil,
          ancestors: [moj.name, csg.name].join(" > "),
          login_count: 0,
          last_login_at: nil,
          updates_count: 0,
          percent_complete: person_one.completion_score,
        },
        {
          id: person_one.id,
          full_name: person_one.name,
          address: nil,
          team_name: ds.name,
          team_role: "Tester",
          main_email_address: person_one.email,
          main_phone_number: nil,
          alternative_phone_number: nil,
          alternative_email_address: nil,
          ancestors: [moj.name, csg.name].join(" > "),
          login_count: 0,
          last_login_at: nil,
          updates_count: 0,
          percent_complete: person_one.completion_score,
        },
        {
          id: person_one.id,
          full_name: person_one.name,
          address: nil,
          team_name: csg.name,
          team_role: "Business Analyst",
          main_email_address: person_one.email,
          main_phone_number: nil,
          alternative_phone_number: nil,
          alternative_email_address: nil,
          ancestors: moj.name,
          login_count: 0,
          last_login_at: nil,
          updates_count: 0,
          percent_complete: person_one.completion_score,
        },
        {
          id: person_two.id,
          full_name: person_two.name,
          address: nil,
          team_name: nil,
          team_role: nil,
          main_email_address: person_two.email,
          main_phone_number: nil,
          alternative_phone_number: nil,
          alternative_email_address: nil,
          ancestors: nil,
          login_count: 2,
          last_login_at: "22-05-2017",
          updates_count: 0,
          percent_complete: person_two.completion_score,
        },
        {
          id: person_three.id,
          full_name: person_three.name,
          address: person_three.location,
          team_name: nil,
          team_role: nil,
          main_email_address: person_three.email,
          main_phone_number: nil,
          alternative_phone_number: nil,
          alternative_email_address: nil,
          ancestors: nil,
          login_count: 3,
          last_login_at: "21-05-2016",
          updates_count: 2,
          percent_complete: person_three.completion_score,
        },
      ]
    end

    it "returns an array of hashes" do
      expect(data).to be_an_instance_of(Array)
      expect(data.first).to be_an_instance_of(Hash)
    end

    it "returns expected attributes" do
      expected_attributes.each do |attribute|
        expect(data.first).to have_key attribute
      end
    end

    it "returns expected collections and format" do
      expect(data).to match_array expected_collections
    end
  end
end
