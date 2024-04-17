class HealthCheckController < ActionController::Base # rubocop:disable Rails/ApplicationController
  protect_from_forgery with: :exception

  def index
    checks = {
      database: alive?(HealthCheck::Database.new),
      search: alive?(HealthCheck::OpenSearch.new),
    }

    unless checks.values.all?
      status = :service_unavailable
      Sentry.capture_message(checks)
    end
    render status:, json: {
      checks:,
    }
  end

private

  def alive?(check)
    check.available? && check.accessible?
  rescue StandardError
    false
  end
end
