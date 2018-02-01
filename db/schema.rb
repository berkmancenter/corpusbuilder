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

ActiveRecord::Schema.define(version: 20180131143632) do

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

  create_table "graphemes_revisions", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_graphemes_revisions_on_grapheme_id_and_revision_id"
  end

  create_table "graphemes_revisions_11beff04_315c_4db1_baf9_86a464eaecf9", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_11beff04315c4db1baf986a464eaecf9_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_11beff04315c4db1baf986a464eaecf9_revision_id"
  end

  create_table "graphemes_revisions_1ffc348e_808d_4e6f_86cd_bdfa2669e087", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_1ffc348e808d4e6f86cdbdfa2669e087_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_1ffc348e808d4e6f86cdbdfa2669e087_revision_id"
  end

  create_table "graphemes_revisions_221f422e_b1cd_4dbc_b7ac_b61da8f83120", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_221f422eb1cd4dbcb7acb61da8f83120_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_221f422eb1cd4dbcb7acb61da8f83120_revision_id"
  end

  create_table "graphemes_revisions_2868be83_96a5_4cef_912d_f564144520e3", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_2868be8396a54cef912df564144520e3_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_2868be8396a54cef912df564144520e3_revision_id"
  end

  create_table "graphemes_revisions_360b04d3_22d0_46af_8c1a_0a5fc35f26a8", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_360b04d322d046af8c1a0a5fc35f26a8_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_360b04d322d046af8c1a0a5fc35f26a8_revision_id"
  end

  create_table "graphemes_revisions_412f8dd6_4cef_4246_a114_9066fc170006", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_412f8dd64cef4246a1149066fc170006_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_412f8dd64cef4246a1149066fc170006_revision_id"
  end

  create_table "graphemes_revisions_44fdf2cb_cfd9_481c_9b94_27fd89e92d02", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_44fdf2cbcfd9481c9b9427fd89e92d02_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_44fdf2cbcfd9481c9b9427fd89e92d02_revision_id"
  end

  create_table "graphemes_revisions_4ffe29ed_fb31_4642_8a3e_92bb0cf8a64a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_4ffe29edfb3146428a3e92bb0cf8a64a_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_4ffe29edfb3146428a3e92bb0cf8a64a_revision_id"
  end

  create_table "graphemes_revisions_517711b8_bb37_4353_8f01_27cae08965a5", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_517711b8bb3743538f0127cae08965a5_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_517711b8bb3743538f0127cae08965a5_revision_id"
  end

  create_table "graphemes_revisions_8da0930f_e17f_4657_9b48_ef4cca213fc1", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_8da0930fe17f46579b48ef4cca213fc1_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_8da0930fe17f46579b48ef4cca213fc1_revision_id"
  end

  create_table "graphemes_revisions_a44df27a_88e2_4ff4_be60_9b6495883221", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_a44df27a88e24ff4be609b6495883221_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_a44df27a88e24ff4be609b6495883221_revision_id"
  end

  create_table "graphemes_revisions_bebf03a2_b288_48bd_99e8_139d60cb76da", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_bebf03a2b28848bd99e8139d60cb76da_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_bebf03a2b28848bd99e8139d60cb76da_revision_id"
  end

  create_table "graphemes_revisions_eef64a05_fb7f_4837_9493_25cb7b8073d4", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_eef64a05fb7f4837949325cb7b8073d4_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_eef64a05fb7f4837949325cb7b8073d4_revision_id"
  end

  create_table "graphemes_revisions_fbd04ec0_bd47_4d15_8da6_ab6fb459ba20", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_fbd04ec0bd474d158da6ab6fb459ba20_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_fbd04ec0bd474d158da6ab6fb459ba20_revision_id"
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

  create_table "que_jobs", primary_key: ["queue", "priority", "run_at", "job_id"], force: :cascade, comment: "3" do |t|
    t.integer "priority", limit: 2, default: 100, null: false
    t.datetime "run_at", default: -> { "now()" }, null: false
    t.bigserial "job_id", null: false
    t.text "job_class", null: false
    t.json "args", default: [], null: false
    t.integer "error_count", default: 0, null: false
    t.text "last_error"
    t.text "queue", default: "", null: false
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

  create_table "zones", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "document_id"
    t.box "area"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "surface_id", null: false
    t.index ["area"], name: "index_zones_on_area", using: :gist
    t.index ["surface_id"], name: "index_zones_on_surface_id"
  end

end
