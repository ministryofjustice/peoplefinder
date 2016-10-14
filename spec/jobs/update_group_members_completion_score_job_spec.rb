require 'rails_helper'

RSpec.describe UpdateGroupMembersCompletionScoreJob, type: :model do

  include ActiveJob::TestHelper

  let(:parent) { nil }
  let(:group) { double(parent: parent) }

  context 'config' do
    subject(:job) { described_class.new }
    it "enqueues as low priority" do
      expect(job.queue_name).to eq 'low_priority'
    end
  end

  context 'enqueuing' do
    let!(:group) { create(:group) }
    subject { Proc.new { described_class.perform_later(group) } }

    it 'enqueues on low priority queue' do
      is_expected.to have_enqueued_job(UpdateGroupMembersCompletionScoreJob).on_queue('low_priority')
    end

    it 'enqueues with group params' do
     is_expected.to have_enqueued_job.with(group)
    end
  end

  context '#error_handler' do
    let!(:group) { create(:group) }
    before { group.destroy! }
    subject(:enqueue_job) { described_class.perform_later(group) }

    it 'rescues from ActiveJob::DeserializationError' do
      expect_any_instance_of(described_class).to receive(:error_handler).with(ActiveJob::DeserializationError)
      perform_enqueued_jobs { enqueue_job }
    end

    it 'logs the error' do
      logger = double
      expect(Rails).to receive(:logger).and_return(logger)
      expect(logger).to receive(:warn).with(/#{described_class}/)
      perform_enqueued_jobs { enqueue_job }
    end

    it 'tests if original exception arises from deleted records' do
      expect_any_instance_of(ActiveJob::DeserializationError).to receive(:original_exception).and_return(ActiveRecord::RecordNotFound)
      perform_enqueued_jobs { enqueue_job }
    end

    xit 'returns success to prevent retry of job' do
      # TODO: how
    end
  end

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
