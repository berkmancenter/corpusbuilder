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

ActiveRecord::Schema.define(version: 20180307082649) do

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
    t.string "backend", default: "tesseract"
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

  create_table "graphemes_revisions_0944d73f_d35d_413e_8386_663d04f64753", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_11a92e22_b61f_4cb9_940f_5e2150ac59ec", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_12edc72d_7216_4df3_aa76_4989325800c7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_1dca8984_573c_45ef_bf06_a8f22a34aae7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_1f28b78e_9b43_435f_9042_dbf62cd2ed88", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_251a21e6_9856_4e21_9c85_0a66fd4d52a7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_2607883e_d0bb_4ff8_8be5_a114b67ca986", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_265110e3_d1ee_47e6_a1c7_94149af161c1", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_26cfe4da_0da3_4de8_8451_8ba7fe27e798", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_2aa99a57_6126_4aef_ae4a_efc1dce5951a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_2e3fae51_9aa9_414d_862a_b75e7e0b669a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_304be037_554d_4345_a72e_3b5bd187845f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_3586d0a4_31b2_43c9_ac34_b563061b8348", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_402d17d8_e5a7_46f0_9a5f_584eaa0f0f0f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_48b08737_f740_40cb_b789_22593968791f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_4a05f89e_0c17_43d9_b45e_06cf347f2484", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_4c723229_583e_44ec_b0bd_4729475abd4a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_5278e225_f408_4dac_88c7_ad16ee3bc8ed", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_59384d3a_627e_4cf7_98db_1e7018103fb9", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_596abd3d_381b_4e7a_98f6_d18bfa6c0ce8", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_5b42d930_1f8d_404c_8705_9ea56816ef48", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_65204b87_e1dd_44c3_b70c_05008bf72eda", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_663bfcac_a2c1_4db6_b83f_e044d6993fc5", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_68f77e4d_6f15_4e1f_89f5_3282b9c60da4", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_6d99bc3c_88de_47ae_9833_d3836dbaf1ee", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_6f817b5b_86f8_453b_a911_d6932c2463ae", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_73ddc4b5_8108_4628_abe8_48ff8062aeb6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_7e163999_540d_42d8_b89b_49a22fbca2e6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_838562c2_1187_4b53_8516_d6ebdb3170be", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_95cc7556_1087_4862_acd0_2d05361f8c82", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_9aa3f87e_38b8_41c4_9a33_360841305c55", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_9ba231db_44c3_40a3_8bab_60037c32855b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_9ccc5284_7101_4a3d_9bfe_4039cf6897b6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_ae63e107_b30c_437b_be54_511118a0b132", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_b41b11eb_c224_42b9_894a_6c2c18f3d37c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_b968d4b3_8ee1_4473_a90f_74aa928c7cfc", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_bb2587f4_2303_4898_aee1_43a4206cd824", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_c48847cd_3312_4ad1_84b9_acd109d6849e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_c5e2cbdb_88ab_4fb3_9f07_b762ce2d28a6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_c7c3ee9e_ba4f_4952_bb63_cfcdd768a5db", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_cbecc474_1065_4e60_b9de_ea0f669b4796", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_cc70717f_a401_4940_8491_4e72170137f2", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_e2060778_23e2_4874_8ea9_f669db733ff1", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_e6bfbb53_a2a8_4b30_ab4f_bfe000e70085", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_e7bf98ad_cb0b_4c1e_a15c_6c87540eed0c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_e7f7caa8_38f4_4950_85a7_ae90387c4195", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_e915ee9c_ad2b_4537_9779_48a789a149b4", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_ec6e7f81_dee1_4543_9927_319bdf1eaec6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_f22518f0_75dc_47c8_a558_c4989775d2eb", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_f39305f9_6b69_4405_b431_77b538abd3d7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_f3a2a4c1_e23f_42a0_955f_60a1ded6a388", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_fa21a24c_2e09_4fc5_be5c_113a80a9a11a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_ffc7a87a_f19c_4d51_b684_94eb70b8d023", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_test1", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
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
    t.decimal "position_weight", precision: 12, scale: 6, default: "0.0"
    t.index ["area"], name: "index_zones_on_area", using: :gist
    t.index ["surface_id"], name: "index_zones_on_surface_id"
  end

  add_foreign_key "graphemes_revisions_6f817b5b_86f8_453b_a911_d6932c2463ae", "graphemes", name: "test_grapheme_id_fk"
  add_foreign_key "graphemes_revisions_cc70717f_a401_4940_8491_4e72170137f2", "graphemes", name: "test_grapheme_id_fk"
  add_foreign_key "test", "graphemes", name: "test_grapheme_id_fk"
end
