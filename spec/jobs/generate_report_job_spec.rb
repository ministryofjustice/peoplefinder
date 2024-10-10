require "rails_helper"

RSpec.describe GenerateReportJob, type: :job do
  subject(:job) { described_class.new }

  let(:csv_report) { CsvPublisher::UserBehaviorReport }
  let(:serialized_csv_report) { csv_report.name }

  let(:perform_later) { described_class.perform_later(serialized_csv_report) }
  let(:perform_now) { described_class.perform_now(serialized_csv_report) }

  context "when enqueued" do
    it "enqueues with appropriate config settings" do
      expect(job.queue_name).to eq "generate_report"
      expect(job.max_run_time).to eq 10.minutes
      expect(job.max_attempts).to eq 3
      expect(job.destroy_failed_jobs?).to be true
    end

    it "enqueues job with expected arguments" do
      expect {
        perform_later
      }.to have_enqueued_job(described_class).with(serialized_csv_report)
    end

    it "enqueues on named queue" do
      expect {
        perform_later
      }.to have_enqueued_job(described_class).on_queue("generate_report")
    end
  end

  context "when performed" do
    it "uses the injected report object to publish the report" do
      expect(csv_report).to receive(:publish!)
      perform_now
    end
  end
end
