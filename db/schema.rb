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

ActiveRecord::Schema.define(version: 20180308120321) do

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

  create_table "graphemes_revisions_00ee5504_4904_4694_a099_e6939839552f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_06b3cbad_2d65_455b_a0e6_68d74241e9f5", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_06ed8e43_7a7f_48d7_a87b_a5b1df9cd95e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_0e9a4124_7175_4bef_a339_c802d7adba32", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_1003e397_c116_404f_887d_b107c49f5a3c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_10bcf577_39a9_44e4_8e14_909ce8ff4421", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_13b666dd_6f68_4c9e_8e05_143dd9d6dd70", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_193d099f_08e6_4876_96ef_cf086230ad3e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_23464e13_f7df_4bb4_9827_9bf1096359ef", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_271ef68a_fb74_4cd3_9fae_7337c1e2130c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_28c8db65_3b94_4c97_ad0c_c5cc34e9a706", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_29494dd8_3a0f_4fc9_a597_5e675e3bd675", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_2a5749ba_9fc9_4000_9dfd_9b8481c5d503", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_2b1290a5_ea2b_4cbd_9dbc_6ff335cfd296", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_3286d17d_8caf_4070_b3e9_e10c33a32854", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_36cddff5_62dc_4dad_840c_6e61af4c6b51", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_38155916_17aa_496c_b0bd_391f4ee7a32f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_3aaa6d64_6427_46d4_a9ca_c5cdc391ee3d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_3b347da1_aa90_4937_b53f_ce28ca70f81e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_48d5d3c8_59de_4fed_8752_3a73ebc9265f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_5072eb9d_701e_4325_bed4_23c0a6232b28", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_58410404_cb25_40bd_bce4_1a8bf97b62d3", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_63c3f90c_7b86_40bf_b6e3_3f6eae4bb1fe", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_745fa431_3cd0_4c5d_acb4_ffa05f14761d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_77eb8225_17d1_4cd7_9e7e_e8526eb27937", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_8188f14a_c314_4f32_a9f9_1df8b46f250e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_8b65dba1_7c05_4fb2_86fe_1c3517e563eb", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_91dcb3f3_0694_4037_8df0_66adafd0f009", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_9768a0dc_02a2_45ad_a83b_7a6c6cdd34f7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_97b89822_87a2_4a4a_af9c_dab713275e36", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_9b9bbe91_0f3c_4a69_84ad_98ab36ea3764", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_aacdaa41_1b9f_45c7_92ac_e47f8d0e23b3", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_b30cca65_3ce6_4920_8af7_c6b9750de579", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_b85fff03_2e67_4572_b636_abfd6d727c4a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_b90367bd_bb6d_412b_add4_f43c71e3d271", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_bef4a4bf_66e1_48d9_b011_1463ec64f7c2", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_c306fb44_22c5_43d3_be58_f463d31c4389", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_c3528627_c6a8_462e_90bb_92d1786a24d4", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_c45ad720_e8fd_4562_8eb9_6d5859bd1fa6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_c9cbaed5_7443_458f_81d7_364ee3300ec1", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_c9d3e819_5588_409a_bb4a_704a67be1f17", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_ca82c042_c51b_4738_981a_9195a1b49485", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_cc7c3d90_d18f_4319_b906_75e6c0d94844", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_cd305b4b_8439_4aa4_aab8_c481c7404c40", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_d61ed7aa_28b7_4ce6_b873_4e1a4b670e79", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_d7bdeaac_495b_462d_bcbf_a50e3bbba63f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_dba20ed4_3d4a_4614_8634_3b3758ef5f92", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_e3464c03_de88_4a89_81f9_988d803700f2", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_e5138aa3_63c6_4c10_9de8_6b1a573b455c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_e7e083fc_e2d0_45cd_92a1_b42c3c2136ed", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_ec7515a0_2115_4fe8_b4fa_c9be3776033a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_efdaa65d_f2a1_4673_adc3_b98a49e61e04", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_f0082726_5b50_4466_8dfa_504b3a665a0d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_f37fd67f_cd1f_4d93_91d7_95f3215ff05b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_f47c9d36_e885_4e57_9475_95c29a59a18a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_fa65c9af_5499_4cb6_979a_3ec91fa86eaa", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_fb8bcb58_ac57_40a0_aa1d_cdde636a8358", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_ff825251_0e61_42b3_b54d_c658319c98ce", id: false, force: :cascade do |t|
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
    t.decimal "position_weight", precision: 12, scale: 6, default: "0.0"
    t.integer "direction", default: 0
    t.index ["area"], name: "index_zones_on_area", using: :gist
    t.index ["surface_id"], name: "index_zones_on_surface_id"
  end

end
