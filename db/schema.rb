# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_03_05_134247) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "actions", force: :cascade do |t|
    t.bigint "data_set_id"
    t.integer "requester_id"
    t.integer "approver_id"
    t.datetime "approved"
    t.string "comment"
    t.string "request_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_set_id"], name: "index_actions_on_data_set_id"
  end

  create_table "csv_data", force: :cascade do |t|
    t.string "service_slug"
    t.integer "data_set_version"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "data_sets", force: :cascade do |t|
    t.bigint "service_id"
    t.integer "version"
    t.string "change_notes"
    t.string "processing_error"
    t.string "state"
    t.string "archiving_error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id", "version"], name: "index_data_sets_on_service_id_and_version"
    t.index ["service_id"], name: "index_data_sets_on_service_id"
  end

  create_table "place_archives", force: :cascade do |t|
    t.string "service_slug"
    t.integer "data_set_version"
    t.string "name"
    t.string "source_address"
    t.string "address1"
    t.string "address2"
    t.string "town"
    t.string "postcode"
    t.string "access_notes"
    t.string "general_notes"
    t.string "url"
    t.string "email"
    t.string "phone"
    t.string "fax"
    t.string "text_phone"
    t.geography "location", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.float "override_lat"
    t.float "override_lng"
    t.string "geocode_error"
    t.string "gss"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "places", force: :cascade do |t|
    t.string "service_slug"
    t.integer "data_set_version"
    t.string "name"
    t.string "source_address"
    t.string "address1"
    t.string "address2"
    t.string "town"
    t.string "postcode"
    t.string "access_notes"
    t.string "general_notes"
    t.string "url"
    t.string "email"
    t.string "phone"
    t.string "fax"
    t.string "text_phone"
    t.geography "location", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.float "override_lat"
    t.float "override_lng"
    t.string "geocode_error"
    t.string "gss"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_slug", "data_set_version"], name: "index_places_on_service_slug_and_data_set_version"
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.integer "active_data_set_version", default: 1
    t.string "source_of_data"
    t.string "location_match_type", default: "nearest"
    t.string "local_authority_hierarchy_match_type", default: "district"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "govuk_url"
    t.string "govuk_title"
    t.index ["slug"], name: "index_services_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid"
    t.string "organisation_slug"
    t.string "organisation_content_id"
    t.string "app_name"
    t.text "permissions"
    t.boolean "remotely_signed_out", default: false
    t.boolean "disabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
