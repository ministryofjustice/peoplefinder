require 'rails_helper'

RSpec.describe UpdateGroupMembersCompletionScoreJob, type: :job do

  let(:group) { double }

  context 'when called' do
    it 'recalculates members average completion score' do
      expect(group).to receive(:update_members_completion_score!)

      described_class.perform_now(group)
    end
  end
end
