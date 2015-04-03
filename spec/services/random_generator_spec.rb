require 'rails_helper'

RSpec.describe RandomGenerator do
  let(:group) { create(:group) }
  subject { described_class.new(group) }

  describe '#clear' do
    let!(:same_level_group) { create(:group) }
    let!(:child_group) { create(:group, parent: group) }
    let!(:grand_child_group) { create(:group, parent: child_group) }

    before do
      subject.clear
    end

    it 'deletes all ancestors' do
      expect { child_group.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { grand_child_group.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
    it 'does not delete groups which are not ancestors' do
      expect(same_level_group.reload).to eql(same_level_group)
    end
  end

  describe '#generate' do
    let(:groups_levels) { 2 }
    let(:groups_per_level) { 2 }
    let(:people_per_group) { 3 }
    let(:domain) { 'fake.digital.justice.gov.uk' }
    before do
      subject.generate(groups_levels, groups_per_level, people_per_group, domain)
    end

    it 'generate all levels of groups' do
      expect(group.descendants.count).to be(6)
    end
    it 'generate people for the leaf groups' do
      expect(Person.all_in_groups(group.descendants.pluck(:id)).count).to be(12)
    end
  end
end
