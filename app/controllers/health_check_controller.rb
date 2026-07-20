class HealthCheckController < ActionController::Base # rubocop:disable Rails/ApplicationController
  protect_from_forgery with: :exception

  def index
    database = HealthCheck::Database.new

    checks = {
      database: alive?(database),
    }

    unless checks.values.all?
      status = :internal_server_error

      errors = {
        database: database.errors,
      }
      Sentry.capture_message("Healthcheck failed: #{errors}")
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
