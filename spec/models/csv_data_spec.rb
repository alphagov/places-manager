require "rails_helper"

RSpec.describe(CsvData, type: :model) do
  context "associations" do
    before do
      @service = Service.create!(slug: "chickens", name: "Chickens!")
      @data_set = @service.data_sets.create!(version: 2)
      @csv_data = CsvData.create!(service_slug: "chickens", data_set_version: 2, data: "1,2,3")
    end

    it "can look up the service it belongs to" do
      expect(@csv_data.service).to(eq(@service))
    end

    it "can look up the data set it belongs to" do
      s = Service.create!(slug: "ducks", name: "Ducks!")
      s.data_sets.create!(version: 2)
      expect(@csv_data.data_set).to(eq(@data_set))
    end
  end

  context "validations" do
    it "is invalid without a service slug" do
      csv_data = CsvData.new(service_slug: nil, data_set_version: 2, data: "1,2,3")
      expect(csv_data.valid?).to be false
      expect(csv_data.errors[:service_slug].size).to(eq(1))
    end

    it "is invalid without a data set version" do
      csv_data = CsvData.new(service_slug: "foo", data_set_version: nil, data: "1,2,3")
      expect(csv_data.valid?).to be false
      expect(csv_data.errors[:data_set_version].size).to(eq(1))
    end

    it "is invalid without data" do
      csv_data = CsvData.new(service_slug: "foo", data_set_version: 2, data: nil)
      expect(csv_data.valid?).to be false
      expect(csv_data.errors[:data].size).to(eq(1))
    end

    context "validating file size" do
      before do
        @service = Service.create!(slug: "chickens", name: "Chickens!")
        @data_set = @service.data_sets.create!(version: 2)
      end

      it "is valid with a file up to 15M" do
        csv_data = CsvData.new(service_slug: "chickens", data_set_version: 2, data: ("x" * (15.megabytes - 1)))
        expect(csv_data.valid?).to(eq(true))
      end

      it "is invalid with a file over 15M" do
        csv_data = CsvData.new(service_slug: "chickens", data_set_version: 2, data: ("x" * (15.megabytes + 1)))
        expect(csv_data.valid?).to be false
        expect(csv_data.errors[:data].size).to(eq(1))
      end
    end

    context "handling various file encodings" do
      before do
        @csv_data = CsvData.new(service_slug: "foo", data_set_version: 2)
      end

      it "handles ASCII files" do
        @csv_data.data_file = File.open(fixture_file_path("encodings/ascii.csv"), encoding: "ascii-8bit")
        @csv_data.save!
        expected = File.read(fixture_file_path("encodings/ascii.csv"))
        expect(@csv_data.data).to(eq(expected))
      end

      it "handle UTF-8 files" do
        @csv_data.data_file = File.open(fixture_file_path("encodings/utf-8.csv"), encoding: "ascii-8bit")
        @csv_data.save!
        expected = File.read(fixture_file_path("encodings/utf-8.csv"))
        expect(@csv_data.data).to(eq(expected))
      end

      it "handles UTF-8 file with BOM" do
        @csv_data.data_file = File.open(fixture_file_path("encodings/utf-8-bom.csv"))
        @csv_data.save!
        expected = File.read(fixture_file_path("encodings/utf-8.csv"))
        expect(@csv_data.data).to(eq(expected))
      end

      it "handles ISO-8859-1 files" do
        @csv_data.data_file = File.open(fixture_file_path("encodings/iso-8859-1.csv"), encoding: "ascii-8bit")
        @csv_data.save!
        expected = File.read(fixture_file_path("encodings/iso-8859-1.csv")).force_encoding("iso-8859-1").encode("utf-8")
        expect(@csv_data.data).to(eq(expected))
      end

      it "handles Windows 1252 files" do
        @csv_data.data_file = File.open(fixture_file_path("encodings/windows-1252.csv"), encoding: "ascii-8bit")
        @csv_data.save!
        expected = File.read(fixture_file_path("encodings/windows-1252.csv")).force_encoding("windows-1252").encode("utf-8")
        expect(@csv_data.data).to(eq(expected))
      end

      it "raises an error with an unknown file encoding" do
        expect {
          @csv_data.data_file = File.open(fixture_file_path("encodings/utf-16le.csv"), encoding: "ascii-8bit")
        }.to(raise_error(InvalidCharacterEncodingError))
      end
    end
  end
end
