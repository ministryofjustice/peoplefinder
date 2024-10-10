require "rails_helper"

RSpec.describe Report, :csv_report, type: :model do
  let(:report) { create(:report) }

  it { is_expected.to respond_to :to_csv_file }
  it { is_expected.to respond_to :client_filename }

  describe "#to_csv_file" do
    subject(:csv_file) { report.to_csv_file }

    let(:file_path) { Rails.root.join("tmp", "reports", "#{report.name}.#{report.extension}") }

    it { is_expected.to eql file_path.to_s }
    it { expect { csv_file }.to have_created_file file_path }
    it { is_expected.to have_file_content report.content }
  end

  describe "#client_filename" do
    it "includes name of report" do
      expect(report.client_filename).to include report.name
    end

    it "includes date report updated" do
      expect(report.client_filename).to include report.updated_at.strftime("%d-%m-%Y-%H-%M-%S")
    end
  end
end
