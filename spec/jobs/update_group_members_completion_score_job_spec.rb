require 'rails_helper'

RSpec.describe UpdateGroupMembersCompletionScoreJob, type: :job do

  let(:parent) { nil }
  let(:group) { double(parent: parent) }

  context 'when called' do
    before do
      allow(group).to receive(:update_members_completion_score!)
    end

    it 'recalculates members average completion score' do
      expect(group).to receive(:update_members_completion_score!)
      described_class.perform_now(group)
    end

    context 'with group with nil parent' do
      it 'does not create new job for parent' do
        expect(described_class).not_to receive(:perform_later).with(parent)
        described_class.perform_now(group)
      end
    end

    context 'with group with a parent' do
      let(:parent) { double }

      it 'creates new job to update parent' do
        expect(described_class).to receive(:perform_later).with(parent)
        described_class.perform_now(group)
      end
    end

    context 'with group with root department as parent' do
      let(:parent) { Group.department }

      it 'does not create new job for parent' do
        expect(described_class).not_to receive(:perform_later).with(parent)
        described_class.perform_now(group)
      end
    end
  end
end
