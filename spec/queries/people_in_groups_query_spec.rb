require 'rails_helper'

describe PeopleInGroupsQuery do

  let(:group) { create :group }

  describe '#call' do
    it 'generates the expected sql' do
      expect(PeopleInGroupsQuery.new([2, 10]).call.to_sql).to match_sql expected_sql
    end

    it 'returns an arel relation' do
      expect(PeopleInGroupsQuery.new([group]).call).to be_an_instance_of(Person::ActiveRecord_Relation)
    end

    context 'finding' do
      before(:all) do
        PermittedDomain.create(domain: 'digital.justice.gov.uk') unless PermittedDomain.exists?(domain: 'digital.justice.gov.uk')
        @moj = create :department
        @ds = create  :group, name: 'Digital Services', parent: @moj
        @ds_dev = create :group, name: 'Digital Development', parent: @ds
        @ds_content = create :group, name: 'Content', parent: @ds
        @laa = create :group, name: 'LAA'
        @laa_tech =  create :group, name: 'LAA Tech', parent: @laa
        @laa_admin = create :group, name: 'LAA Admin', parent: @laa

        @moj_emp_0 = create :person, groups: [@moj]
        @ds_dev_content_emp_1 = create :person, groups: [@ds_dev, @ds_content]
        @ds_dev_emp2 = create :person, groups: [@ds_dev]
        @ds_content_emp3 = create :person, groups: [@ds_content]
        @laa_tech_emp4 = create :person, groups: [@laa_tech]
        @laa_admin_emp5 = create :person, groups: [@laa_admin]
      end

      after(:all) do
        PermittedDomain.destroy_all
        Group.destroy_all
        Membership.destroy_all
        Person.destroy_all
      end

      it 'finds all employees in the moj' do
        expect(PeopleInGroupsQuery.new([@moj]).call).to match_array([@moj_emp_0])
      end

      it 'finds all employees in DS dev' do
        expect(PeopleInGroupsQuery.new([@ds_dev]).call).to match_array([@ds_dev_content_emp_1, @ds_dev_emp2])
      end

      it 'finds all employees in DS Dev And Content' do
        expect(PeopleInGroupsQuery.new([@ds_dev, @ds_content]).call).to match_array([@ds_dev_content_emp_1, @ds_dev_emp2, @ds_content_emp3])
      end

      it 'finds all employees if one group not given as an array' do
        expect(PeopleInGroupsQuery.new(@laa_tech).call).to match_array([@laa_tech_emp4])
      end

      it 'finds all employees if just the id of the group is given' do
        expect(PeopleInGroupsQuery.new(@ds_dev.id).call).to match_array([@ds_dev_content_emp_1, @ds_dev_emp2])
      end

      it 'finds all employees if multipls ids are given in an array' do
        expect(PeopleInGroupsQuery.new([@ds_dev.id, @ds_content.id]).call).to match_array([@ds_dev_content_emp_1, @ds_dev_emp2, @ds_content_emp3])
      end
    end

    def expected_sql
      %q(
        SELECT "people".* FROM
        (
         SELECT DISTINCT people.*,
            string_agg(CASE role WHEN '' THEN NULL ELSE role END, ', ' ORDER BY role) AS role_names
         FROM "people" INNER JOIN "memberships" ON "memberships"."person_id" = "people"."id"
         WHERE "memberships"."group_id" IN (2, 10)
         GROUP BY "people"."id"
         ORDER BY "people"."surname" ASC, "people"."given_name" ASC) people
         ORDER BY "people"."surname" ASC, "people"."given_name" ASC
      )
    end
  end
end
