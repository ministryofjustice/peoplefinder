unless Rails.env.test?
  require 'prometheus_exporter/middleware'
  require 'prometheus_exporter/instrumentation'

  # This reports stats per request like HTTP status and timings
  Rails.application.middleware.unshift PrometheusExporter::Middleware
  # Delayed job metrics
  PrometheusExporter::Instrumentation::DelayedJob.register_plugin
end
