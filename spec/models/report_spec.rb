require 'rails_helper'

RSpec.describe Report, type: :model, csv_report: true do

  it { is_expected.to respond_to :to_csv_file }
  it { is_expected.to respond_to :client_filename }

  let(:report) { create(:report) }

  describe '#to_csv_file' do
    subject { report.to_csv_file }

    let(:file_path) { Rails.root.join('tmp', 'reports', report.name + '.' + report.extension) }

    it { is_expected.to eql file_path.to_s }
    it { expect { subject }.to have_created_file file_path }
    it { is_expected.to have_file_content report.content }
  end

  describe '#client_filename' do
    subject { report.client_filename }

    it 'includes name of report' do
      is_expected.to include report.name
    end

    it 'includes date report updated' do
      is_expected.to include report.updated_at.strftime('%d-%m-%Y-%H-%M-%S')
    end
  end
end
