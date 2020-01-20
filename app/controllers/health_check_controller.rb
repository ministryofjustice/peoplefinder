class HealthCheckController < ActionController::Base

  protect_from_forgery with: :exception

  def index
    Rails.logger.silence do
      report = HealthCheckService.new.report

      if report.status == '200'
        render json: report
      else
        render json: report, status: '500'
      end
    end
  end
end
