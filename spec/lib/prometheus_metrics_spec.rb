RSpec.describe PrometheusMetrics do
  describe ".register" do
    it "registers the prometheus metric" do
      described_class::GAUGES.each do |gauge|
        expect(PrometheusExporter::Client.default)
          .to receive(:register)
          .with(:gauge, "places_manager_#{gauge[:name]}", gauge[:description])
      end

      described_class.register
    end
  end

  describe ".name_with_prefix" do
    it "prefixes the metric name with 'places_manager_'" do
      expect(described_class.name_with_prefix("gauge_metric")).to eq("places_manager_gauge_metric")
    end
  end

  describe ".observe" do
    let(:metric) { instance_double(PrometheusExporter::Client::RemoteMetric) }

    before do
      allow(metric).to receive(:observe)
    end

    it "updates the metric if a metric with that name exists" do
      allow(PrometheusExporter::Client.default).to receive(:find_registered_metric).and_return(metric)

      described_class.observe("places_manager_gauge_metric", 1)

      expect(metric).to have_received(:observe).with(1, {})
    end
  end
end
