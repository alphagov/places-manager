require "rails_helper"

module Admin
  RSpec.describe(DataSetsController, type: :controller) do
    before do
      clean_db
      @service = FactoryBot.create(:service)
      stub_locations_api_does_not_have_a_postcode("IG6 3HJ")
      Sidekiq::Testing.inline!
      Sidekiq::Worker.clear_all
    end

    describe "POST create" do
      before do
        @request.env["HTTP_REFERER"] = "http://localhost:3000/admin/services/#{@service.id}"
      end

      it "successfully imports a CSV file" do
        as_gds_editor do
          csv_file = fixture_file_upload(Rails.root.join("spec/fixtures/good_csv.csv"), "text/csv")
          post(:create, params: { service_id: @service.id, data_set: { data_file: csv_file } })
          assert_response(:redirect)
          expect(Service.first.data_sets.count).to(eq(2))
          expect(Place.count).to(eq(1))
          place = Place.first
          expect(place.name).to(eq("1 Stop Instruction"))
          expect(place.address1).to(eq("Power League"))
          expect(place.address2).to(eq("Forest Road"))
          expect(place.town).to(eq("Ilford (Fairlop)"))
          expect(place.postcode).to(eq("IG6 3HJ"))
          expect(place.access_notes).to(eq("Some access notes"))
          expect(place.general_notes).to(eq("Some general notes"))
          expect(place.url).to(eq("http://www.1stopinstruction.com"))
          expect(place.email).to(eq("info@1stopinstruction.com"))
          expect(place.phone).to(eq("0800 848 8418"))
          expect(place.fax).to(eq("0800 848 8419"))
          expect(place.text_phone).to(eq("0800 848 8420"))
        end
      end

      it "handles CSV files in a strange character encoding" do
        allow_any_instance_of(DataSet).to receive(:data_file=).and_raise(InvalidCharacterEncodingError)
        as_gds_editor do
          csv_file = fixture_file_upload(Rails.root.join("spec/fixtures/good_csv.csv"), "text/csv")
          post(:create, params: { service_id: @service.id, data_set: { data_file: csv_file } })
          assert_response(:unprocessable_entity)
          assert_template("admin/data_sets/new")
          expect(Service.first.data_sets.count).to(eq(1))
          expect(Place.count).to(eq(0))
        end
      end

      it "displays a new data form if the data set can't be created" do
        as_gds_editor do
          Tempfile.create("too-much-data") do |tmpfile|
            tmpfile.write("x" * (15.megabytes + 1))
            tmpfile.close
            csv_file = fixture_file_upload(tmpfile.path, "text/csv")
            post(:create, params: { service_id: @service.id, data_set: { data_file: csv_file } })
            assert_response(:success)
            assert_template("admin/data_sets/new")
            expect(Service.first.data_sets.count).to(eq(1))
            expect(Place.count).to(eq(0))
          end
        end
      end

      it "rejects if user is not in the test department" do
        as_other_department_user do
          csv_file = fixture_file_upload(Rails.root.join("spec/fixtures/good_csv.csv"), "text/csv")
          post(:create, params: { service_id: @service.id, data_set: { data_file: csv_file } })
          assert_response(:forbidden)
        end
      end
    end

    describe "POST 'activate'" do
      before do
        ArchivePlacesWorker.jobs.clear
        Sidekiq::Testing.fake!
      end

      it "allows activating a data_set" do
        as_gds_editor do
          set = @service.data_sets.create!
          post(:activate, params: { service_id: @service.id, id: set.id })
          assert_response(:redirect)
          expect(flash[:success]).to(eq("Data Set #{set.version} successfully activated"))
          @service.reload
          expect(@service.active_data_set).to(eq(set))
        end
      end

      it "does not allow activating a data_set that hasn't completed processing" do
        as_gds_editor do
          set = @service.data_sets.create!(data_file: File.open(fixture_file_path("good_csv.csv")))
          post(:activate, params: { service_id: @service.id, id: set.id })
          assert_response(:redirect)
          expect(flash[:danger]).to(eq("Couldn't activate data set"))
          @service.reload
          expect(@service.active_data_set).to_not(eq(set))
        end
      end

      it "does not allow activating a data_set if user is not in the test department" do
        as_other_department_user do
          set = @service.data_sets.create!(data_file: File.open(fixture_file_path("good_csv.csv")))
          post(:activate, params: { service_id: @service.id, id: set.id })
          assert_response(:forbidden)
        end
      end

      context("when activating the latest data set") do
        it "creates a background job for archiving the place information" do
          as_gds_editor do
            post(:activate, params: { service_id: @service.id, id: @service.latest_data_set.id })
            job = ArchivePlacesWorker.jobs.last
            service_id_to_process = job["args"].first
            expect(Service.find(service_id_to_process)).to(eq(@service))
            expect(ArchivePlacesWorker.jobs.count).to(eq(1))
          end
        end

        it "creates a background job for deleting historic records" do
          as_gds_editor do
            post(:activate, params: { service_id: @service.id, id: @service.latest_data_set.id })
            job = DeleteHistoricRecordsWorker.jobs.last
            service_id_to_process = job["args"].first
            expect(Service.find(service_id_to_process)).to(eq(@service))
            expect(DeleteHistoricRecordsWorker.jobs.count).to(eq(1))
          end
        end
      end
    end
  end
end
