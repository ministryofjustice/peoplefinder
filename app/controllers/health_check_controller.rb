class HealthCheckController < ActionController::Base # rubocop:disable Rails/ApplicationController
  protect_from_forgery with: :exception

  def index
    report = HealthCheckService.new.report

    if report.status == "200"
      render json: report
    else
      render json: report, status: "500"
    end
  end
end
