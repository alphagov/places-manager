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

ActiveRecord::Schema[8.1].define(version: 2026_04_29_104715) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "postgis"

  create_table "actions", force: :cascade do |t|
    t.datetime "approved"
    t.integer "approver_id"
    t.string "comment"
    t.datetime "created_at", null: false
    t.bigint "data_set_id"
    t.string "request_type"
    t.integer "requester_id"
    t.datetime "updated_at", null: false
    t.index ["data_set_id"], name: "index_actions_on_data_set_id"
  end

  create_table "csv_data", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "data"
    t.integer "data_set_version"
    t.string "service_slug"
    t.datetime "updated_at", null: false
  end

  create_table "data_sets", force: :cascade do |t|
    t.string "archiving_error"
    t.string "change_notes"
    t.datetime "created_at", null: false
    t.string "processing_error"
    t.bigint "service_id"
    t.string "state"
    t.datetime "updated_at", null: false
    t.integer "version"
    t.index ["service_id", "version"], name: "index_data_sets_on_service_id_and_version"
    t.index ["service_id"], name: "index_data_sets_on_service_id"
  end

  create_table "place_archives", force: :cascade do |t|
    t.string "access_notes"
    t.string "address1"
    t.string "address2"
    t.datetime "created_at", null: false
    t.integer "data_set_version"
    t.string "email"
    t.string "fax"
    t.string "general_notes"
    t.string "geocode_error"
    t.string "gss"
    t.geography "location", limit: {srid: 4326, type: "st_point", geographic: true}
    t.string "name"
    t.float "override_lat"
    t.float "override_lng"
    t.string "phone"
    t.string "postcode"
    t.string "service_slug"
    t.string "source_address"
    t.string "text_phone"
    t.string "town"
    t.datetime "updated_at", null: false
    t.string "url"
  end

  create_table "places", force: :cascade do |t|
    t.string "access_notes"
    t.string "address1"
    t.string "address2"
    t.datetime "created_at", null: false
    t.integer "data_set_version"
    t.string "email"
    t.string "fax"
    t.string "general_notes"
    t.string "geocode_error"
    t.string "gss"
    t.geography "location", limit: {srid: 4326, type: "st_point", geographic: true}
    t.string "map_marker_colour"
    t.string "map_marker_symbol"
    t.string "name"
    t.float "override_lat"
    t.float "override_lng"
    t.string "phone"
    t.string "postcode"
    t.string "service_slug"
    t.string "source_address"
    t.string "text_phone"
    t.string "town"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["service_slug", "data_set_version"], name: "index_places_on_service_slug_and_data_set_version"
  end

  create_table "services", force: :cascade do |t|
    t.integer "active_data_set_version", default: 1
    t.datetime "created_at", null: false
    t.string "local_authority_hierarchy_match_type", default: "district"
    t.string "location_match_type", default: "nearest"
    t.string "name"
    t.string "organisation_slugs", default: [], array: true
    t.string "slug"
    t.string "source_of_data"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_services_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "app_name"
    t.datetime "created_at", null: false
    t.boolean "disabled", default: false
    t.string "email"
    t.string "name"
    t.string "organisation_content_id"
    t.string "organisation_slug"
    t.text "permissions"
    t.boolean "remotely_signed_out", default: false
    t.string "uid"
    t.datetime "updated_at", null: false
  end
end
