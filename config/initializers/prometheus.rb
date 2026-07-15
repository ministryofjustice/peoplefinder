# Locally there's no metrics sidecar on port 9394, so Prometheus clients log
# repeated "Connection refused" errors. Start the exporter in-process for
# development only to give them a collector and silence those errors.
#
# Once running, metrics are available at http://localhost:9394/metrics
#
# Source: https://www.rubydoc.info/gems/govuk_app_config/9.24.1
if Rails.env.development?
  require "govuk_app_config/govuk_prometheus_exporter"
  GovukPrometheusExporter.configure
end
