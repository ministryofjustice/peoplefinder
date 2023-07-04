require "rails_helper"

RSpec.describe RandomGenerator do
  include PermittedDomainHelper

  subject(:random_generator) { described_class.new(group) }

  let(:group) { create(:group) }

  describe "#clear" do
    let!(:same_level_group) { create(:group) }
    let!(:child_group) { create(:group, parent: group) }
    let!(:grand_child_group) { create(:group, parent: child_group) }

    before do
      random_generator.clear
    end

    it "deletes all ancestors" do
      expect { child_group.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { grand_child_group.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not delete groups which are not ancestors" do
      expect(same_level_group.reload).to eql(same_level_group)
    end
  end

  describe "#generate" do
    let(:groups_levels) { 2 }
    let(:groups_per_level) { 2 }
    let(:people_per_group) { 3 }
    let(:domain) { "digital.justice.gov.uk" }

    before do
      random_generator.generate(groups_levels, groups_per_level, people_per_group, domain)
    end

    it "adds permitted domain" do
      expect(PermittedDomain.pluck(:domain)).to include domain
    end

    it "generates all levels of groups" do
      expect(group.descendants.count).to eq(6)
    end

    it "generates people for the leaf groups" do
      expect(Person.all_in_groups(group.descendants.pluck(:id)).count).to eq(30)
    end
  end

  describe "#generate_members" do
    it "generates people for the specified leaf group" do
      expect { random_generator.generate_members(3) }.to change(group.people, :count).by 3
    end
  end
end
