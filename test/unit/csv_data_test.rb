require "test_helper"

class CsvDataTest < ActiveSupport::TestCase
  context "associations" do
    setup do
      @service = Service.create! slug: "chickens", name: "Chickens!"
      @data_set = @service.data_sets.create! version: 2
      @csv_data = CsvData.create!(
        service_slug: "chickens",
        data_set_version: 2,
        data: "1,2,3",
      )
    end

    should "can look up the service it belongs to" do
      assert_equal @service, @csv_data.service
    end

    should "can look up the data set it belongs to" do
      s = Service.create! slug: "ducks", name: "Ducks!"
      s.data_sets.create! version: 2

      assert_equal @data_set, @csv_data.data_set
    end
  end

  context "validations" do
    should "be invalid without a service slug" do
      csv_data = CsvData.new(service_slug: nil, data_set_version: 2, data: "1,2,3")
      assert_not csv_data.valid?
      assert_equal 1, csv_data.errors[:service_slug].size
    end

    should "be invalid without a data set version" do
      csv_data = CsvData.new(service_slug: "foo", data_set_version: nil, data: "1,2,3")
      assert_not csv_data.valid?
      assert_equal 1, csv_data.errors[:data_set_version].size
    end

    should "be invalid without data" do
      csv_data = CsvData.new(service_slug: "foo", data_set_version: 2, data: nil)
      assert_not csv_data.valid?
      assert_equal 1, csv_data.errors[:data].size
    end

    context "validating file size" do
      setup do
        @service = Service.create! slug: "chickens", name: "Chickens!"
        @data_set = @service.data_sets.create! version: 2
      end

      should "be valid with a file up to 15M" do
        csv_data = CsvData.new(service_slug: "chickens", data_set_version: 2, data: "x" * (15.megabytes - 1))
        assert csv_data.valid?
      end

      should "be invalid with a file over 15M" do
        csv_data = CsvData.new(service_slug: "chickens", data_set_version: 2, data: "x" * (15.megabytes + 1))
        assert_not csv_data.valid?
        assert_equal 1, csv_data.errors[:data].size
      end
    end

    context "handling various file encodings" do
      setup do
        @csv_data = CsvData.new(service_slug: "foo", data_set_version: 2)
      end

      should "handle ASCII files" do
        @csv_data.data_file = File.open(fixture_file_path("encodings/ascii.csv"), encoding: "ascii-8bit")
        @csv_data.save!
        expected = File.read(fixture_file_path("encodings/ascii.csv"))
        assert_equal expected, @csv_data.data
      end

      should "handle UTF-8 files" do
        @csv_data.data_file = File.open(fixture_file_path("encodings/utf-8.csv"), encoding: "ascii-8bit")
        @csv_data.save!
        expected = File.read(fixture_file_path("encodings/utf-8.csv"))
        assert_equal expected, @csv_data.data
      end

      should "handle ISO-8859-1 files" do
        @csv_data.data_file = File.open(fixture_file_path("encodings/iso-8859-1.csv"), encoding: "ascii-8bit")
        @csv_data.save!
        expected = File.read(fixture_file_path("encodings/iso-8859-1.csv")).force_encoding("iso-8859-1").encode("utf-8")
        assert_equal expected, @csv_data.data
      end

      should "handle Windows 1252 files" do
        @csv_data.data_file = File.open(fixture_file_path("encodings/windows-1252.csv"), encoding: "ascii-8bit")
        @csv_data.save!
        expected = File.read(fixture_file_path("encodings/windows-1252.csv")).force_encoding("windows-1252").encode("utf-8")
        assert_equal expected, @csv_data.data
      end

      should "raise an error with an unknown file encoding" do
        assert_raise InvalidCharacterEncodingError do
          @csv_data.data_file = File.open(fixture_file_path("encodings/utf-16le.csv"), encoding: "ascii-8bit")
        end
      end
    end
  end
end
