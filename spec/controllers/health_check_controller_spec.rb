require 'spec_helper'

describe HealthCheckController, type: :controller do
  describe 'INDEX' do
    it 'returns  200 if successful' do
      service = double HealthCheckService
      report = HealthCheckService::HealthCheckReport.new(
        '200', 'All Components OK'
      )
      expect(HealthCheckService).to receive(:new).and_return(service)
      expect(service).to receive(:report).and_return(report)

      get :index
      expect(response.status).to eq(200)
      expect(response.body).to eq report.to_json
    end

    it 'returns 500 if unsuccessful' do
      service = double HealthCheckService
      report = HealthCheckService::HealthCheckReport.new(
        '500', ['Error message 1', 'Error message 2']
      )
      expect(HealthCheckService).to receive(:new).and_return(service)
      expect(service).to receive(:report).and_return(report)

      get :index
      expect(response.status).to eq(500)
      expect(response.body).to eq report.to_json
    end
  end
end
