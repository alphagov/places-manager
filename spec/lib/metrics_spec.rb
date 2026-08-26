require "rails_helper"

RSpec.describe Metrics do
  describe ".csv_import_time" do
    it "sends data on time taken to import a csv" do
      end_time = Time.zone.now
      start_time = end_time - end_time.min
      import_time = (end_time - start_time)

      expect(PrometheusMetrics).to receive(:observe).with("csv_import_time", import_time, {
        service_slug: "service-slug",
        dataset_version: 1,
        csv_size: 5.megabytes,
      })

      described_class.csv_import_time("service-slug", 1, 5.megabytes, import_time)
    end
  end
end
