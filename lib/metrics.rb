class Metrics
  def self.csv_import_time(slug, version, csv_size, import_time)
    PrometheusMetrics.observe("csv_import_time", import_time, {
      service_slug: slug,
      dataset_version: version,
      csv_size: csv_size,
    })
  end
end
