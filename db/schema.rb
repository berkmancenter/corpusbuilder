# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180301102910) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "administrators", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.string "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "annotations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content"
    t.uuid "editor_id"
    t.box "areas", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "surface_number"
    t.integer "mode", default: 0
    t.json "payload", default: {}
    t.integer "status", default: 0
  end

  create_table "annotations_revisions", id: false, force: :cascade do |t|
    t.uuid "annotation_id", null: false
    t.uuid "revision_id", null: false
  end

  create_table "apps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "secret", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "branches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "revision_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "editor_id"
  end

  create_table "correction_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.uuid "editor_id", null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "author"
    t.string "authority"
    t.date "date"
    t.string "editor"
    t.string "license"
    t.text "notes"
    t.string "publisher"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", null: false
    t.uuid "app_id", null: false
  end

  create_table "editors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "graphemes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "zone_id", null: false
    t.box "area", null: false
    t.string "value", limit: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "certainty", precision: 5, scale: 4, default: "0.0"
    t.integer "status", default: 0
    t.uuid "parent_ids", default: [], array: true
    t.decimal "position_weight", precision: 12, scale: 6
  end

  create_table "graphemes_revisions_6f817b5b_86f8_453b_a911_d6932c2463ae", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_cc70717f_a401_4940_8491_4e72170137f2", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "images", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "image_scan"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "document_id"
    t.integer "order", default: 0
    t.string "hocr"
    t.string "processed_image"
  end

  create_table "pipelines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.integer "status"
    t.uuid "document_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "data", default: {}
  end

  create_table "revisions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "document_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "parent_id"
    t.integer "status", default: 0
    t.uuid "merged_with_id"
  end

  create_table "surfaces", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "document_id", null: false
    t.box "area", null: false
    t.integer "number", null: false
    t.uuid "image_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area"], name: "index_surfaces_on_area", using: :gist
  end

  create_table "test", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "zones", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "document_id"
    t.box "area"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "surface_id", null: false
    t.index ["area"], name: "index_zones_on_area", using: :gist
    t.index ["surface_id"], name: "index_zones_on_surface_id"
  end

  add_foreign_key "graphemes_revisions_6f817b5b_86f8_453b_a911_d6932c2463ae", "graphemes", name: "test_grapheme_id_fk"
  add_foreign_key "graphemes_revisions_cc70717f_a401_4940_8491_4e72170137f2", "graphemes", name: "test_grapheme_id_fk"
  add_foreign_key "test", "graphemes", name: "test_grapheme_id_fk"
end
