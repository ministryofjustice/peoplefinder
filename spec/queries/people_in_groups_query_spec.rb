require "rails_helper"

describe PeopleInGroupsQuery do
  let(:group) { create :group }

  describe "#call" do
    it "generates the expected sql" do
      expect(described_class.new([2, 10]).call.to_sql).to match_sql expected_sql
    end

    it "returns an arel relation" do
      expect(described_class.new([group]).call).to be_an_instance_of(Person.const_get(:ActiveRecord_Relation))
    end

    context "when finding" do
      let(:moj) { create :department }
      let(:ds) { create  :group, name: "Digital Services", parent: moj }
      let(:ds_dev) { create :group, name: "Digital Development", parent: ds }
      let(:ds_content) { create :group, name: "Content", parent: ds }
      let(:laa) { create :group, name: "LAA" }
      let(:laa_tech) { create :group, name: "LAA Tech", parent: laa }
      let(:laa_admin) { create :group, name: "LAA Admin", parent: laa }
      let(:moj_emp_0) { create :person, groups: [moj] }
      let(:ds_dev_content_emp_1) { create :person, groups: [ds_dev, ds_content] }
      let(:ds_dev_emp2) { create :person, groups: [ds_dev] }
      let(:ds_content_emp3) { create :person, groups: [ds_content] }
      let(:laa_tech_emp4) { create :person, groups: [laa_tech] }
      let(:laa_admin_emp5) { create :person, groups: [laa_admin] }

      before do
        PermittedDomain.create!(domain: "digital.justice.gov.uk") unless PermittedDomain.exists?(domain: "digital.justice.gov.uk")
      end

      it "finds all employees in the moj" do
        expect(described_class.new([moj]).call).to contain_exactly(moj_emp_0)
      end

      it "finds all employees in DS dev" do
        expect(described_class.new([ds_dev]).call).to contain_exactly(ds_dev_content_emp_1, ds_dev_emp2)
      end

      it "finds all employees in DS Dev And Content" do
        expect(described_class.new([ds_dev, ds_content]).call).to contain_exactly(ds_dev_content_emp_1, ds_dev_emp2, ds_content_emp3)
      end

      it "finds all employees if one group not given as an array" do
        expect(described_class.new(laa_tech).call).to contain_exactly(laa_tech_emp4)
      end

      it "finds all employees if just the id of the group is given" do
        expect(described_class.new(ds_dev.id).call).to contain_exactly(ds_dev_content_emp_1, ds_dev_emp2)
      end

      it "finds all employees if multipls ids are given in an array" do
        expect(described_class.new([ds_dev.id, ds_content.id]).call).to contain_exactly(ds_dev_content_emp_1, ds_dev_emp2, ds_content_emp3)
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
