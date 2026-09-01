require "govuk_app_config/govuk_prometheus_exporter"
require "prometheus_metrics"

GovukPrometheusExporter.configure

Rails.configuration.after_initialize do
  PrometheusMetrics.register
end
