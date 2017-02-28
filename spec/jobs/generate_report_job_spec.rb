require 'rails_helper'

RSpec.describe GenerateReportJob, type: :job do

  let(:csv_report) { CsvPublisher::UserBehaviorReport }
  let(:serialized_csv_report) do
    {
      'json_class' => csv_report.name
    }.to_json
  end

  subject(:perform_later) { described_class.perform_later(serialized_csv_report) }
  subject(:perform_now) { described_class.perform_now(serialized_csv_report) }
  subject(:job) { described_class.new }

  context 'when enqueued' do
    it "enqueues with appropriate config settings" do
      expect(job.queue_name).to eq 'generate_report'
      expect(job.max_run_time).to eq 10.minutes
      expect(job.max_attempts).to eq 3
      expect(job.destroy_failed_jobs?).to eq true
    end

    it 'enqueues job with expected arguments' do
      expect do
        perform_later
      end.to have_enqueued_job(described_class).with(serialized_csv_report)
    end

    it 'enqueues on named queue' do
      expect do
        perform_later
      end.to have_enqueued_job(described_class).on_queue('generate_report')
    end
  end

  context 'when performed' do
    it 'uses the injected report object to publish the report' do
      expect(csv_report).to receive(:publish!)
      perform_now
    end
  end

end
