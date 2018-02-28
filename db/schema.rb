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

ActiveRecord::Schema.define(version: 20180228130000) do

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

  create_table "graphemes_revisions", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_graphemes_revisions_on_grapheme_id_and_revision_id"
  end

  create_table "graphemes_revisions_012b8dbb_7c6b_4d3f_9adf_46044deb5728", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_012b8dbb7c6b4d3f9adf46044deb5728_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_012b8dbb7c6b4d3f9adf46044deb5728_revision_id"
  end

  create_table "graphemes_revisions_01e15da0_1f17_4205_b66c_0925919c176c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_01e15da01f174205b66c0925919c176c_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_01e15da01f174205b66c0925919c176c_revision_id"
  end

  create_table "graphemes_revisions_03839a72_00a3_4c28_a461_aa177a9e3686", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_03839a7200a34c28a461aa177a9e3686_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_03839a7200a34c28a461aa177a9e3686_revision_id"
  end

  create_table "graphemes_revisions_03c8d6c3_fdf4_42db_ab01_795a5666ab93", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_03c8d6c3fdf442dbab01795a5666ab93_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_03c8d6c3fdf442dbab01795a5666ab93_revision_id"
  end

  create_table "graphemes_revisions_057bc1a3_bba4_47aa_be87_e0096193e29c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_057bc1a3bba447aabe87e0096193e29c_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_057bc1a3bba447aabe87e0096193e29c_revision_id"
  end

  create_table "graphemes_revisions_07ab398b_25fe_45c2_aa30_095c1d7b6e4c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_07ab398b25fe45c2aa30095c1d7b6e4c_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_07ab398b25fe45c2aa30095c1d7b6e4c_revision_id"
  end

  create_table "graphemes_revisions_0811c7dd_8441_4337_a6dc_4da6073c266e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_0811c7dd84414337a6dc4da6073c266e_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_0811c7dd84414337a6dc4da6073c266e_revision_id"
  end

  create_table "graphemes_revisions_08680a86_ea3d_4627_b471_2b4f5fafbca1", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_08680a86ea3d4627b4712b4f5fafbca1_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_08680a86ea3d4627b4712b4f5fafbca1_revision_id"
  end

  create_table "graphemes_revisions_0ac00749_fc1a_4f0c_9b78_32a83bc4b664", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_0ac00749fc1a4f0c9b7832a83bc4b664_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_0ac00749fc1a4f0c9b7832a83bc4b664_revision_id"
  end

  create_table "graphemes_revisions_0b63eb9b_eece_4c45_b9c4_2cffe4403251", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_0b63eb9beece4c45b9c42cffe4403251_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_0b63eb9beece4c45b9c42cffe4403251_revision_id"
  end

  create_table "graphemes_revisions_0dd6a70c_9f97_43ce_9c3c_10c7539d5f3e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_0dd6a70c9f9743ce9c3c10c7539d5f3e_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_0dd6a70c9f9743ce9c3c10c7539d5f3e_revision_id"
  end

  create_table "graphemes_revisions_0f5b0abe_e333_49ee_9bdc_310cb2f2582b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_0f5b0abee33349ee9bdc310cb2f2582b_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_0f5b0abee33349ee9bdc310cb2f2582b_revision_id"
  end

  create_table "graphemes_revisions_0f5fc078_93aa_4efe_aa31_bdd68863a4f2", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_0f5fc07893aa4efeaa31bdd68863a4f2_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_0f5fc07893aa4efeaa31bdd68863a4f2_revision_id"
  end

  create_table "graphemes_revisions_10ec1fe7_7362_4e23_8475_656e61613065", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_10ec1fe773624e238475656e61613065_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_10ec1fe773624e238475656e61613065_revision_id"
  end

  create_table "graphemes_revisions_11b74718_2ff9_4e6f_a72a_934669d49af6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_11b747182ff94e6fa72a934669d49af6_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_11b747182ff94e6fa72a934669d49af6_revision_id"
  end

  create_table "graphemes_revisions_1291c660_4bff_4b77_8baf_1dc2331a1179", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_1291c6604bff4b778baf1dc2331a1179_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_1291c6604bff4b778baf1dc2331a1179_revision_id"
  end

  create_table "graphemes_revisions_13a868cd_0a8b_4aaf_88fa_05f2b701858b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_13a868cd0a8b4aaf88fa05f2b701858b_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_13a868cd0a8b4aaf88fa05f2b701858b_revision_id"
  end

  create_table "graphemes_revisions_1725b2d4_dd04_4445_8fad_eda5fe532806", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_1725b2d4dd0444458fadeda5fe532806_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_1725b2d4dd0444458fadeda5fe532806_revision_id"
  end

  create_table "graphemes_revisions_178f0c05_2af3_406e_95c8_ae153f9e8a4e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_178f0c052af3406e95c8ae153f9e8a4e_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_178f0c052af3406e95c8ae153f9e8a4e_revision_id"
  end

  create_table "graphemes_revisions_1ae1ff42_1ac7_4e5f_81f1_a9b71a01570c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_1ae1ff421ac74e5f81f1a9b71a01570c_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_1ae1ff421ac74e5f81f1a9b71a01570c_revision_id"
  end

  create_table "graphemes_revisions_1bb70226_f92b_4cfe_b0b4_c0c44cd7681a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_1bb70226f92b4cfeb0b4c0c44cd7681a_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_1bb70226f92b4cfeb0b4c0c44cd7681a_revision_id"
  end

  create_table "graphemes_revisions_1e711dc2_be27_4556_9e45_2858bdbda885", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_1e711dc2be2745569e452858bdbda885_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_1e711dc2be2745569e452858bdbda885_revision_id"
  end

  create_table "graphemes_revisions_22ca487d_1a77_4c2b_a1cd_a0ed31337aec", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_22ca487d1a774c2ba1cda0ed31337aec_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_22ca487d1a774c2ba1cda0ed31337aec_revision_id"
  end

  create_table "graphemes_revisions_2328759b_526a_49ac_83f5_73186a3817f8", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_2328759b526a49ac83f573186a3817f8_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_2328759b526a49ac83f573186a3817f8_revision_id"
  end

  create_table "graphemes_revisions_26171d4c_c405_47d6_8c76_3dd4df3cee3a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_26171d4cc40547d68c763dd4df3cee3a_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_26171d4cc40547d68c763dd4df3cee3a_revision_id"
  end

  create_table "graphemes_revisions_272f8f65_e8ba_4147_af58_e5963c6d4ffe", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_272f8f65e8ba4147af58e5963c6d4ffe_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_272f8f65e8ba4147af58e5963c6d4ffe_revision_id"
  end

  create_table "graphemes_revisions_27b5cb77_12e6_4487_9d3a_34d71ce2e036", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_27b5cb7712e644879d3a34d71ce2e036_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_27b5cb7712e644879d3a34d71ce2e036_revision_id"
  end

  create_table "graphemes_revisions_2a6b8237_93df_4891_8455_d3558e89cb3f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_2a6b823793df48918455d3558e89cb3f_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_2a6b823793df48918455d3558e89cb3f_revision_id"
  end

  create_table "graphemes_revisions_2b40b15f_66c0_40e3_90ea_d8fb1f1e8f9e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_2b40b15f66c040e390ead8fb1f1e8f9e_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_2b40b15f66c040e390ead8fb1f1e8f9e_revision_id"
  end

  create_table "graphemes_revisions_2d41adda_1e0c_4cd8_9d01_568476fab476", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_2d41adda1e0c4cd89d01568476fab476_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_2d41adda1e0c4cd89d01568476fab476_revision_id"
  end

  create_table "graphemes_revisions_2de6348a_6b92_499c_bbd3_425f9bae03e7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_2de6348a6b92499cbbd3425f9bae03e7_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_2de6348a6b92499cbbd3425f9bae03e7_revision_id"
  end

  create_table "graphemes_revisions_2ebd695e_0799_40cd_ab4a_8010f8fb6f39", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_2ebd695e079940cdab4a8010f8fb6f39_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_2ebd695e079940cdab4a8010f8fb6f39_revision_id"
  end

  create_table "graphemes_revisions_3049d2a5_df72_4cb8_b35b_8390626ec4b2", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_3049d2a5df724cb8b35b8390626ec4b2_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_3049d2a5df724cb8b35b8390626ec4b2_revision_id"
  end

  create_table "graphemes_revisions_30aa6935_338c_48bd_b2e9_bdeeea3637a7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_30aa6935338c48bdb2e9bdeeea3637a7_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_30aa6935338c48bdb2e9bdeeea3637a7_revision_id"
  end

  create_table "graphemes_revisions_30ba080a_b22b_4b31_aa19_74c64d6774fa", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_30ba080ab22b4b31aa1974c64d6774fa_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_30ba080ab22b4b31aa1974c64d6774fa_revision_id"
  end

  create_table "graphemes_revisions_316f9b2d_6f07_41dc_92eb_087ac6e654d6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_316f9b2d6f0741dc92eb087ac6e654d6_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_316f9b2d6f0741dc92eb087ac6e654d6_revision_id"
  end

  create_table "graphemes_revisions_345a8cec_860b_4b7b_9e37_57d44ce7d22f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_345a8cec860b4b7b9e3757d44ce7d22f_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_345a8cec860b4b7b9e3757d44ce7d22f_revision_id"
  end

  create_table "graphemes_revisions_36abf413_7aa1_4c4a_8a26_52b492418d41", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_36abf4137aa14c4a8a2652b492418d41_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_36abf4137aa14c4a8a2652b492418d41_revision_id"
  end

  create_table "graphemes_revisions_371c6f5c_5327_44ea_beac_7948616de6b7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_371c6f5c532744eabeac7948616de6b7_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_371c6f5c532744eabeac7948616de6b7_revision_id"
  end

  create_table "graphemes_revisions_37bfa2f3_9fee_4b0f_9482_386a2e2bcace", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_37bfa2f39fee4b0f9482386a2e2bcace_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_37bfa2f39fee4b0f9482386a2e2bcace_revision_id"
  end

  create_table "graphemes_revisions_3849ee42_c06f_4e16_a1ee_771afbf43d86", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_3849ee42c06f4e16a1ee771afbf43d86_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_3849ee42c06f4e16a1ee771afbf43d86_revision_id"
  end

  create_table "graphemes_revisions_3d3c27b1_551b_482d_b233_13ad3f7ee5f8", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_3d3c27b1551b482db23313ad3f7ee5f8_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_3d3c27b1551b482db23313ad3f7ee5f8_revision_id"
  end

  create_table "graphemes_revisions_3fa78a41_a191_4670_85ec_f26535d56817", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_3fa78a41a191467085ecf26535d56817_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_3fa78a41a191467085ecf26535d56817_revision_id"
  end

  create_table "graphemes_revisions_4127dae0_f21e_4cdd_9074_c0ec2c8c54d8", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_4127dae0f21e4cdd9074c0ec2c8c54d8_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_4127dae0f21e4cdd9074c0ec2c8c54d8_revision_id"
  end

  create_table "graphemes_revisions_434d7e86_be6c_4bd8_80e9_bb55ad82dcc8", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_434d7e86be6c4bd880e9bb55ad82dcc8_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_434d7e86be6c4bd880e9bb55ad82dcc8_revision_id"
  end

  create_table "graphemes_revisions_45806bc7_e5ef_4389_876c_551bbc7cfaf9", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_45806bc7e5ef4389876c551bbc7cfaf9_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_45806bc7e5ef4389876c551bbc7cfaf9_revision_id"
  end

  create_table "graphemes_revisions_45aedd4c_a132_489b_a9ff_2d53de543075", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_45aedd4ca132489ba9ff2d53de543075_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_45aedd4ca132489ba9ff2d53de543075_revision_id"
  end

  create_table "graphemes_revisions_479b4219_c26b_48a9_b990_213d07366af9", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_479b4219c26b48a9b990213d07366af9_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_479b4219c26b48a9b990213d07366af9_revision_id"
  end

  create_table "graphemes_revisions_48ef707b_16a7_4a6f_8b29_51dc22d9dcb6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_48ef707b16a74a6f8b2951dc22d9dcb6_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_48ef707b16a74a6f8b2951dc22d9dcb6_revision_id"
  end

  create_table "graphemes_revisions_495acfbb_58a1_4e1d_8158_bb06a70a32ba", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_495acfbb58a14e1d8158bb06a70a32ba_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_495acfbb58a14e1d8158bb06a70a32ba_revision_id"
  end

  create_table "graphemes_revisions_49beda51_3d62_41ce_addc_6248250b5ed9", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_49beda513d6241ceaddc6248250b5ed9_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_49beda513d6241ceaddc6248250b5ed9_revision_id"
  end

  create_table "graphemes_revisions_4aca4a0b_55bc_485e_b860_c4fe9e1b9dbd", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_4aca4a0b55bc485eb860c4fe9e1b9dbd_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_4aca4a0b55bc485eb860c4fe9e1b9dbd_revision_id"
  end

  create_table "graphemes_revisions_4c52ab5b_f56b_4f42_920f_fd95dfabfda5", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_4c52ab5bf56b4f42920ffd95dfabfda5_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_4c52ab5bf56b4f42920ffd95dfabfda5_revision_id"
  end

  create_table "graphemes_revisions_4eb12c49_eda4_4bb1_9031_681ef3906328", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_4eb12c49eda44bb19031681ef3906328_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_4eb12c49eda44bb19031681ef3906328_revision_id"
  end

  create_table "graphemes_revisions_4eebafce_1c81_4c0b_8496_eeb7aa053932", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_4eebafce1c814c0b8496eeb7aa053932_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_4eebafce1c814c0b8496eeb7aa053932_revision_id"
  end

  create_table "graphemes_revisions_501a0ba6_87b1_47d5_8925_40a3ec105bf1", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_501a0ba687b147d5892540a3ec105bf1_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_501a0ba687b147d5892540a3ec105bf1_revision_id"
  end

  create_table "graphemes_revisions_509fc1bc_d583_43e4_af12_c4ac77ed2ccd", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_509fc1bcd58343e4af12c4ac77ed2ccd_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_509fc1bcd58343e4af12c4ac77ed2ccd_revision_id"
  end

  create_table "graphemes_revisions_562c4de4_d984_4f77_bba2_4faa9eede489", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_562c4de4d9844f77bba24faa9eede489_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_562c4de4d9844f77bba24faa9eede489_revision_id"
  end

  create_table "graphemes_revisions_5702d800_7a22_4120_bdca_dad98a8966d9", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_5702d8007a224120bdcadad98a8966d9_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_5702d8007a224120bdcadad98a8966d9_revision_id"
  end

  create_table "graphemes_revisions_574965a0_6930_4708_9ed3_ffb4827bab36", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_574965a0693047089ed3ffb4827bab36_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_574965a0693047089ed3ffb4827bab36_revision_id"
  end

  create_table "graphemes_revisions_5897ef7e_ad3e_4f8a_ade3_17b44cbd1a70", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_5897ef7ead3e4f8aade317b44cbd1a70_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_5897ef7ead3e4f8aade317b44cbd1a70_revision_id"
  end

  create_table "graphemes_revisions_59856f18_61f8_4700_92eb_8de2f2dce8ac", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_59856f1861f8470092eb8de2f2dce8ac_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_59856f1861f8470092eb8de2f2dce8ac_revision_id"
  end

  create_table "graphemes_revisions_59f72065_f217_4645_80ae_1fd7d7c0e178", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_59f72065f217464580ae1fd7d7c0e178_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_59f72065f217464580ae1fd7d7c0e178_revision_id"
  end

  create_table "graphemes_revisions_5b5f6efc_4ae1_45c5_904c_de05b37067ca", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_5b5f6efc4ae145c5904cde05b37067ca_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_5b5f6efc4ae145c5904cde05b37067ca_revision_id"
  end

  create_table "graphemes_revisions_61835bee_914f_410b_80f8_d01dd2374a6d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_61835bee914f410b80f8d01dd2374a6d_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_61835bee914f410b80f8d01dd2374a6d_revision_id"
  end

  create_table "graphemes_revisions_62c8ef66_8631_4e48_bbf6_db4ac0da9fca", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_62c8ef6686314e48bbf6db4ac0da9fca_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_62c8ef6686314e48bbf6db4ac0da9fca_revision_id"
  end

  create_table "graphemes_revisions_6314bedf_c6f9_4bfd_89cb_9b9cb91d2d24", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_6314bedfc6f94bfd89cb9b9cb91d2d24_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_6314bedfc6f94bfd89cb9b9cb91d2d24_revision_id"
  end

  create_table "graphemes_revisions_64116fa1_678e_4f85_8153_cf580bfe177c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_64116fa1678e4f858153cf580bfe177c_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_64116fa1678e4f858153cf580bfe177c_revision_id"
  end

  create_table "graphemes_revisions_660d2e91_252e_4633_a132_608ed35ae8fd", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_660d2e91252e4633a132608ed35ae8fd_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_660d2e91252e4633a132608ed35ae8fd_revision_id"
  end

  create_table "graphemes_revisions_66103cb3_eb37_4efb_9fc0_cbbfbe89edb6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_66103cb3eb374efb9fc0cbbfbe89edb6_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_66103cb3eb374efb9fc0cbbfbe89edb6_revision_id"
  end

  create_table "graphemes_revisions_6673e4ff_fbba_4f2e_adb1_4b4c0ab34946", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_6673e4fffbba4f2eadb14b4c0ab34946_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_6673e4fffbba4f2eadb14b4c0ab34946_revision_id"
  end

  create_table "graphemes_revisions_68472c67_7e30_41e1_a460_0bcffc8fb1c2", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_68472c677e3041e1a4600bcffc8fb1c2_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_68472c677e3041e1a4600bcffc8fb1c2_revision_id"
  end

  create_table "graphemes_revisions_698fcc43_06c8_4976_b97e_b06aa84b5a00", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_698fcc4306c84976b97eb06aa84b5a00_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_698fcc4306c84976b97eb06aa84b5a00_revision_id"
  end

  create_table "graphemes_revisions_69e635b5_7774_47d2_8177_3c339f186dab", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_69e635b5777447d281773c339f186dab_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_69e635b5777447d281773c339f186dab_revision_id"
  end

  create_table "graphemes_revisions_6ab57ff1_7840_4c76_8267_a41a8217d388", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_6ab57ff178404c768267a41a8217d388_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_6ab57ff178404c768267a41a8217d388_revision_id"
  end

  create_table "graphemes_revisions_6e16efb6_ac2e_4e5c_b3c0_a323fee7ef28", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_6e16efb6ac2e4e5cb3c0a323fee7ef28_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_6e16efb6ac2e4e5cb3c0a323fee7ef28_revision_id"
  end

  create_table "graphemes_revisions_711b8a53_eb84_483b_a5eb_b6d3a3a68343", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_711b8a53eb84483ba5ebb6d3a3a68343_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_711b8a53eb84483ba5ebb6d3a3a68343_revision_id"
  end

  create_table "graphemes_revisions_724abe8b_ece9_4e9c_9430_b2cfd13033db", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_724abe8bece94e9c9430b2cfd13033db_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_724abe8bece94e9c9430b2cfd13033db_revision_id"
  end

  create_table "graphemes_revisions_7483fb77_cf17_4e05_8571_afc3918f06c2", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_7483fb77cf174e058571afc3918f06c2_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_7483fb77cf174e058571afc3918f06c2_revision_id"
  end

  create_table "graphemes_revisions_752ea1e8_6748_42a6_9dae_296b38abac61", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_752ea1e8674842a69dae296b38abac61_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_752ea1e8674842a69dae296b38abac61_revision_id"
  end

  create_table "graphemes_revisions_75db2787_fcbb_423d_a3a6_71d925d8b183", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_75db2787fcbb423da3a671d925d8b183_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_75db2787fcbb423da3a671d925d8b183_revision_id"
  end

  create_table "graphemes_revisions_768cdf91_3fd2_47c1_9595_272ad14e306f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_768cdf913fd247c19595272ad14e306f_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_768cdf913fd247c19595272ad14e306f_revision_id"
  end

  create_table "graphemes_revisions_7a1c85a1_df14_43f9_af84_4ad9124181f0", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_7a1c85a1df1443f9af844ad9124181f0_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_7a1c85a1df1443f9af844ad9124181f0_revision_id"
  end

  create_table "graphemes_revisions_7a399258_6576_420b_91cf_22218631b32b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_7a3992586576420b91cf22218631b32b_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_7a3992586576420b91cf22218631b32b_revision_id"
  end

  create_table "graphemes_revisions_7aea4808_0c59_4e67_b531_e61448b967aa", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_7aea48080c594e67b531e61448b967aa_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_7aea48080c594e67b531e61448b967aa_revision_id"
  end

  create_table "graphemes_revisions_7b0274a5_422a_4497_a694_cdd8063142f5", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_7b0274a5422a4497a694cdd8063142f5_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_7b0274a5422a4497a694cdd8063142f5_revision_id"
  end

  create_table "graphemes_revisions_7b910ebf_56ea_4563_86d0_22b411ea18f5", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_7b910ebf56ea456386d022b411ea18f5_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_7b910ebf56ea456386d022b411ea18f5_revision_id"
  end

  create_table "graphemes_revisions_7bc1c53e_8fc5_49bf_a26e_8c5bbe14ace3", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_7bc1c53e8fc549bfa26e8c5bbe14ace3_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_7bc1c53e8fc549bfa26e8c5bbe14ace3_revision_id"
  end

  create_table "graphemes_revisions_7f64e448_bbc0_4a41_b84e_5a783816a741", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_7f64e448bbc04a41b84e5a783816a741_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_7f64e448bbc04a41b84e5a783816a741_revision_id"
  end

  create_table "graphemes_revisions_7f70a44e_ccd6_409a_a118_afb02cb21513", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_7f70a44eccd6409aa118afb02cb21513_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_7f70a44eccd6409aa118afb02cb21513_revision_id"
  end

  create_table "graphemes_revisions_803bd86f_00e2_4da9_a375_1bd501dd2032", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_803bd86f00e24da9a3751bd501dd2032_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_803bd86f00e24da9a3751bd501dd2032_revision_id"
  end

  create_table "graphemes_revisions_84c2c3b6_7f38_4259_9e4b_a73053efee58", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_84c2c3b67f3842599e4ba73053efee58_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_84c2c3b67f3842599e4ba73053efee58_revision_id"
  end

  create_table "graphemes_revisions_87171548_d4de_459f_8da8_91baa556d171", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_87171548d4de459f8da891baa556d171_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_87171548d4de459f8da891baa556d171_revision_id"
  end

  create_table "graphemes_revisions_88a7d6e8_36a9_4935_994c_ee98664ab50f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_88a7d6e836a94935994cee98664ab50f_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_88a7d6e836a94935994cee98664ab50f_revision_id"
  end

  create_table "graphemes_revisions_89666229_d935_46fb_9a6d_9b926d38768a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_89666229d93546fb9a6d9b926d38768a_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_89666229d93546fb9a6d9b926d38768a_revision_id"
  end

  create_table "graphemes_revisions_8a1f7beb_0609_411d_bdec_6a6248f43053", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_8a1f7beb0609411dbdec6a6248f43053_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_8a1f7beb0609411dbdec6a6248f43053_revision_id"
  end

  create_table "graphemes_revisions_8c9fae30_4563_4cde_91e5_f9c3975f9506", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_8c9fae3045634cde91e5f9c3975f9506_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_8c9fae3045634cde91e5f9c3975f9506_revision_id"
  end

  create_table "graphemes_revisions_8da3c8f6_7bb3_4a60_99b4_4a2cf6356e91", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_8da3c8f67bb34a6099b44a2cf6356e91_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_8da3c8f67bb34a6099b44a2cf6356e91_revision_id"
  end

  create_table "graphemes_revisions_8ff1feeb_d86a_4744_a840_6a26f0bfb165", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_8ff1feebd86a4744a8406a26f0bfb165_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_8ff1feebd86a4744a8406a26f0bfb165_revision_id"
  end

  create_table "graphemes_revisions_90de6843_ac4b_4fe8_90e6_de48ba8bb244", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_90de6843ac4b4fe890e6de48ba8bb244_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_90de6843ac4b4fe890e6de48ba8bb244_revision_id"
  end

  create_table "graphemes_revisions_939cf7a2_731f_44ba_8f4a_6307cc0f1189", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_939cf7a2731f44ba8f4a6307cc0f1189_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_939cf7a2731f44ba8f4a6307cc0f1189_revision_id"
  end

  create_table "graphemes_revisions_93c59017_c5ae_4010_925f_dee6ddab4e4d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_93c59017c5ae4010925fdee6ddab4e4d_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_93c59017c5ae4010925fdee6ddab4e4d_revision_id"
  end

  create_table "graphemes_revisions_959a638e_3280_4590_b202_e2e51889269f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_959a638e32804590b202e2e51889269f_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_959a638e32804590b202e2e51889269f_revision_id"
  end

  create_table "graphemes_revisions_977c0ea4_bac9_416e_a70e_38b64fff0592", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_977c0ea4bac9416ea70e38b64fff0592_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_977c0ea4bac9416ea70e38b64fff0592_revision_id"
  end

  create_table "graphemes_revisions_983fe1c0_3a99_49cd_aeb3_63bcd8ce1c6f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_983fe1c03a9949cdaeb363bcd8ce1c6f_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_983fe1c03a9949cdaeb363bcd8ce1c6f_revision_id"
  end

  create_table "graphemes_revisions_98e83e93_6bef_4953_9543_70693f4b183a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_98e83e936bef4953954370693f4b183a_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_98e83e936bef4953954370693f4b183a_revision_id"
  end

  create_table "graphemes_revisions_a0b5e555_95bb_431e_9663_2c6967b0fade", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_a0b5e55595bb431e96632c6967b0fade_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_a0b5e55595bb431e96632c6967b0fade_revision_id"
  end

  create_table "graphemes_revisions_a107d359_55f6_4add_90ff_4973f0875b0e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_a107d35955f64add90ff4973f0875b0e_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_a107d35955f64add90ff4973f0875b0e_revision_id"
  end

  create_table "graphemes_revisions_a54ceec3_092f_4dc5_8886_714000d36a93", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_a54ceec3092f4dc58886714000d36a93_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_a54ceec3092f4dc58886714000d36a93_revision_id"
  end

  create_table "graphemes_revisions_a6ff1830_f954_47d9_aa4b_9ef68c37a04c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_a6ff1830f95447d9aa4b9ef68c37a04c_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_a6ff1830f95447d9aa4b9ef68c37a04c_revision_id"
  end

  create_table "graphemes_revisions_a76e4034_d539_4fd2_85f7_e3a5941074f4", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_a76e4034d5394fd285f7e3a5941074f4_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_a76e4034d5394fd285f7e3a5941074f4_revision_id"
  end

  create_table "graphemes_revisions_a7c4314d_528e_40ab_b397_8f36bff18ebd", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_a7c4314d528e40abb3978f36bff18ebd_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_a7c4314d528e40abb3978f36bff18ebd_revision_id"
  end

  create_table "graphemes_revisions_a8c14deb_871d_410d_a5a1_17bf3c5d59d6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_a8c14deb871d410da5a117bf3c5d59d6_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_a8c14deb871d410da5a117bf3c5d59d6_revision_id"
  end

  create_table "graphemes_revisions_a99ec561_3b63_4a03_8091_8714f966138f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_a99ec5613b634a0380918714f966138f_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_a99ec5613b634a0380918714f966138f_revision_id"
  end

  create_table "graphemes_revisions_ab64199d_c241_428b_909a_a1b862269ff6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_ab64199dc241428b909aa1b862269ff6_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_ab64199dc241428b909aa1b862269ff6_revision_id"
  end

  create_table "graphemes_revisions_ac70b8c4_cffb_4977_8ec6_9a548f4bf5da", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_ac70b8c4cffb49778ec69a548f4bf5da_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_ac70b8c4cffb49778ec69a548f4bf5da_revision_id"
  end

  create_table "graphemes_revisions_acb0d6ec_de58_4cab_a95b_520cdf3be607", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_acb0d6ecde584caba95b520cdf3be607_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_acb0d6ecde584caba95b520cdf3be607_revision_id"
  end

  create_table "graphemes_revisions_ae011a27_c259_4a16_bfe0_5cab7ceb1f42", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_ae011a27c2594a16bfe05cab7ceb1f42_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_ae011a27c2594a16bfe05cab7ceb1f42_revision_id"
  end

  create_table "graphemes_revisions_b0113ca0_22bd_437b_b25e_f0a521dd8e6b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_b0113ca022bd437bb25ef0a521dd8e6b_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_b0113ca022bd437bb25ef0a521dd8e6b_revision_id"
  end

  create_table "graphemes_revisions_b24ed9e5_27a6_44fc_9cad_b671da7d7098", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_b24ed9e527a644fc9cadb671da7d7098_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_b24ed9e527a644fc9cadb671da7d7098_revision_id"
  end

  create_table "graphemes_revisions_b2ce0c72_825c_4089_b561_39fe4dc98bb5", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_b2ce0c72825c4089b56139fe4dc98bb5_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_b2ce0c72825c4089b56139fe4dc98bb5_revision_id"
  end

  create_table "graphemes_revisions_b412f132_6b9d_40d8_8e99_28e2ad690923", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_b412f1326b9d40d88e9928e2ad690923_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_b412f1326b9d40d88e9928e2ad690923_revision_id"
  end

  create_table "graphemes_revisions_b605c378_d89e_4072_b6b6_7e23077d70c2", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_b605c378d89e4072b6b67e23077d70c2_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_b605c378d89e4072b6b67e23077d70c2_revision_id"
  end

  create_table "graphemes_revisions_b6a9fea7_054a_4509_9b80_2a6c32578d2e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_b6a9fea7054a45099b802a6c32578d2e_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_b6a9fea7054a45099b802a6c32578d2e_revision_id"
  end

  create_table "graphemes_revisions_b702cda5_159d_4510_bc1e_00803c3b18f6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_b702cda5159d4510bc1e00803c3b18f6_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_b702cda5159d4510bc1e00803c3b18f6_revision_id"
  end

  create_table "graphemes_revisions_b78fa332_6f90_43a5_941c_566bdb2bbf56", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_b78fa3326f9043a5941c566bdb2bbf56_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_b78fa3326f9043a5941c566bdb2bbf56_revision_id"
  end

  create_table "graphemes_revisions_bca9d8d3_bcbd_4149_838f_3bc5caea4cad", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_bca9d8d3bcbd4149838f3bc5caea4cad_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_bca9d8d3bcbd4149838f3bc5caea4cad_revision_id"
  end

  create_table "graphemes_revisions_bde58ed7_4e51_47c8_9b81_12cd951893e3", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_bde58ed74e5147c89b8112cd951893e3_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_bde58ed74e5147c89b8112cd951893e3_revision_id"
  end

  create_table "graphemes_revisions_c03d6909_6263_466b_bf51_20b32d82a08d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_c03d69096263466bbf5120b32d82a08d_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_c03d69096263466bbf5120b32d82a08d_revision_id"
  end

  create_table "graphemes_revisions_c0a448c3_535f_4912_87ca_bbfd6e47953c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_c0a448c3535f491287cabbfd6e47953c_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_c0a448c3535f491287cabbfd6e47953c_revision_id"
  end

  create_table "graphemes_revisions_c20625ad_7635_4855_a8b2_4f7ec45c4efe", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_c20625ad76354855a8b24f7ec45c4efe_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_c20625ad76354855a8b24f7ec45c4efe_revision_id"
  end

  create_table "graphemes_revisions_c2a8f337_217f_4ad1_aacf_c51ba5205863", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_c2a8f337217f4ad1aacfc51ba5205863_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_c2a8f337217f4ad1aacfc51ba5205863_revision_id"
  end

  create_table "graphemes_revisions_c2e90c29_a2da_40b7_8752_af71104a0f8d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_c2e90c29a2da40b78752af71104a0f8d_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_c2e90c29a2da40b78752af71104a0f8d_revision_id"
  end

  create_table "graphemes_revisions_c7727593_4750_4eee_aee4_65f0beddaf3e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_c772759347504eeeaee465f0beddaf3e_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_c772759347504eeeaee465f0beddaf3e_revision_id"
  end

  create_table "graphemes_revisions_c8d6dba2_7c75_4b90_a8cb_e331c81063f7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_c8d6dba27c754b90a8cbe331c81063f7_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_c8d6dba27c754b90a8cbe331c81063f7_revision_id"
  end

  create_table "graphemes_revisions_cbaba2c3_531d_4b38_9232_d1dbfb7c8ea1", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_cbaba2c3531d4b389232d1dbfb7c8ea1_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_cbaba2c3531d4b389232d1dbfb7c8ea1_revision_id"
  end

  create_table "graphemes_revisions_cbbe0ec2_f7dd_4be6_b10a_392c59f23afc", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_cbbe0ec2f7dd4be6b10a392c59f23afc_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_cbbe0ec2f7dd4be6b10a392c59f23afc_revision_id"
  end

  create_table "graphemes_revisions_ce35cd85_9fc5_4fbc_befe_baee7c58dcb7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_ce35cd859fc54fbcbefebaee7c58dcb7_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_ce35cd859fc54fbcbefebaee7c58dcb7_revision_id"
  end

  create_table "graphemes_revisions_cf259aae_ea38_4758_9cb2_773e6377c7e7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_cf259aaeea3847589cb2773e6377c7e7_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_cf259aaeea3847589cb2773e6377c7e7_revision_id"
  end

  create_table "graphemes_revisions_cf3fce79_18fb_430f_9ced_e69e375a16a6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_cf3fce7918fb430f9cede69e375a16a6_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_cf3fce7918fb430f9cede69e375a16a6_revision_id"
  end

  create_table "graphemes_revisions_d2ee4685_6daa_4847_9eff_ed46026af3c9", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_d2ee46856daa48479effed46026af3c9_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_d2ee46856daa48479effed46026af3c9_revision_id"
  end

  create_table "graphemes_revisions_d3025ebf_1bd4_404c_89d5_2dcb891ad902", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_d3025ebf1bd4404c89d52dcb891ad902_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_d3025ebf1bd4404c89d52dcb891ad902_revision_id"
  end

  create_table "graphemes_revisions_d4871bb5_d913_4bb5_980b_df39fc2fec48", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_d4871bb5d9134bb5980bdf39fc2fec48_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_d4871bb5d9134bb5980bdf39fc2fec48_revision_id"
  end

  create_table "graphemes_revisions_d571b37a_0901_4659_b312_ba0a4df8f557", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_d571b37a09014659b312ba0a4df8f557_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_d571b37a09014659b312ba0a4df8f557_revision_id"
  end

  create_table "graphemes_revisions_d6782291_1f85_4625_b78a_be0820a28be9", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_d67822911f854625b78abe0820a28be9_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_d67822911f854625b78abe0820a28be9_revision_id"
  end

  create_table "graphemes_revisions_d859b0d7_7570_40aa_8ee8_987aaa7654fa", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_d859b0d7757040aa8ee8987aaa7654fa_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_d859b0d7757040aa8ee8987aaa7654fa_revision_id"
  end

  create_table "graphemes_revisions_d971a139_3380_44a4_aeec_5878be398eef", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_d971a139338044a4aeec5878be398eef_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_d971a139338044a4aeec5878be398eef_revision_id"
  end

  create_table "graphemes_revisions_dbfcd5e0_8619_4453_936a_4d6b7e5bdef4", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_dbfcd5e086194453936a4d6b7e5bdef4_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_dbfcd5e086194453936a4d6b7e5bdef4_revision_id"
  end

  create_table "graphemes_revisions_dccce604_5cc2_4b8e_93bd_c1b93332e3db", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_dccce6045cc24b8e93bdc1b93332e3db_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_dccce6045cc24b8e93bdc1b93332e3db_revision_id"
  end

  create_table "graphemes_revisions_dd994167_62f5_4b31_8ae3_64a56d628074", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_dd99416762f54b318ae364a56d628074_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_dd99416762f54b318ae364a56d628074_revision_id"
  end

  create_table "graphemes_revisions_dee360c3_9772_4eb2_afc4_3bbfaa2d6921", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_dee360c397724eb2afc43bbfaa2d6921_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_dee360c397724eb2afc43bbfaa2d6921_revision_id"
  end

  create_table "graphemes_revisions_df00f64f_a328_4ffc_9fde_5b8d33067d32", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_df00f64fa3284ffc9fde5b8d33067d32_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_df00f64fa3284ffc9fde5b8d33067d32_revision_id"
  end

  create_table "graphemes_revisions_e087d99f_dab6_42a0_9f88_4e203f8d86f7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_e087d99fdab642a09f884e203f8d86f7_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_e087d99fdab642a09f884e203f8d86f7_revision_id"
  end

  create_table "graphemes_revisions_e21f465d_992c_4071_a7bb_3c0c1c8462dd", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_e21f465d992c4071a7bb3c0c1c8462dd_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_e21f465d992c4071a7bb3c0c1c8462dd_revision_id"
  end

  create_table "graphemes_revisions_e3f6695b_5d21_4de3_89b4_c82767d5cb21", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_e3f6695b5d214de389b4c82767d5cb21_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_e3f6695b5d214de389b4c82767d5cb21_revision_id"
  end

  create_table "graphemes_revisions_e436a882_30f3_44b5_9e7d_81e3b08f2af2", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_e436a88230f344b59e7d81e3b08f2af2_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_e436a88230f344b59e7d81e3b08f2af2_revision_id"
  end

  create_table "graphemes_revisions_e451e08c_d1ad_4389_8fd0_370b6792d1a8", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_e451e08cd1ad43898fd0370b6792d1a8_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_e451e08cd1ad43898fd0370b6792d1a8_revision_id"
  end

  create_table "graphemes_revisions_e59c285a_1d9c_473a_b415_9cd662d68702", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_e59c285a1d9c473ab4159cd662d68702_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_e59c285a1d9c473ab4159cd662d68702_revision_id"
  end

  create_table "graphemes_revisions_e8300ec9_5441_4896_9b47_23c902128dfa", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_e8300ec9544148969b4723c902128dfa_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_e8300ec9544148969b4723c902128dfa_revision_id"
  end

  create_table "graphemes_revisions_e8f65093_4a0c_445b_86bd_8a177b9de47c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_e8f650934a0c445b86bd8a177b9de47c_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_e8f650934a0c445b86bd8a177b9de47c_revision_id"
  end

  create_table "graphemes_revisions_e9209fc1_3658_4f1b_8a50_144ca7e3fe49", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_e9209fc136584f1b8a50144ca7e3fe49_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_e9209fc136584f1b8a50144ca7e3fe49_revision_id"
  end

  create_table "graphemes_revisions_ea56484b_d5d7_491f_94e3_1a1068828ff1", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_ea56484bd5d7491f94e31a1068828ff1_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_ea56484bd5d7491f94e31a1068828ff1_revision_id"
  end

  create_table "graphemes_revisions_eda2df10_b0af_48f1_bb0a_3f6ea5de5619", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_eda2df10b0af48f1bb0a3f6ea5de5619_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_eda2df10b0af48f1bb0a3f6ea5de5619_revision_id"
  end

  create_table "graphemes_revisions_ee245d1e_54cf_4d2f_a267_3b85c5c68b75", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_ee245d1e54cf4d2fa2673b85c5c68b75_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_ee245d1e54cf4d2fa2673b85c5c68b75_revision_id"
  end

  create_table "graphemes_revisions_ef3fd70c_a7f4_431f_801f_3afe41e76889", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_ef3fd70ca7f4431f801f3afe41e76889_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_ef3fd70ca7f4431f801f3afe41e76889_revision_id"
  end

  create_table "graphemes_revisions_f06d47cd_0593_4869_a0d5_8824253b0b1f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_f06d47cd05934869a0d58824253b0b1f_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_f06d47cd05934869a0d58824253b0b1f_revision_id"
  end

  create_table "graphemes_revisions_f16e31af_91c0_4aef_a852_acdd40577bcd", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_f16e31af91c04aefa852acdd40577bcd_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_f16e31af91c04aefa852acdd40577bcd_revision_id"
  end

  create_table "graphemes_revisions_f2047958_3379_4d4d_ac74_ead2ed4b0b1f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_f204795833794d4dac74ead2ed4b0b1f_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_f204795833794d4dac74ead2ed4b0b1f_revision_id"
  end

  create_table "graphemes_revisions_f22c963d_9e80_4f15_91e1_4c44153929b7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_f22c963d9e804f1591e14c44153929b7_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_f22c963d9e804f1591e14c44153929b7_revision_id"
  end

  create_table "graphemes_revisions_f33edd54_be9b_4e27_8ba2_baadc729c4fc", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_f33edd54be9b4e278ba2baadc729c4fc_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_f33edd54be9b4e278ba2baadc729c4fc_revision_id"
  end

  create_table "graphemes_revisions_f37c6ef5_f8b0_456d_b9a5_a7388661e3ca", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_f37c6ef5f8b0456db9a5a7388661e3ca_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_f37c6ef5f8b0456db9a5a7388661e3ca_revision_id"
  end

  create_table "graphemes_revisions_f6a6dde4_19aa_4a08_a051_ce2097c7c6ae", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_f6a6dde419aa4a08a051ce2097c7c6ae_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_f6a6dde419aa4a08a051ce2097c7c6ae_revision_id"
  end

  create_table "graphemes_revisions_f713ba01_42dd_4024_a4aa_99e50c88b945", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_f713ba0142dd4024a4aa99e50c88b945_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_f713ba0142dd4024a4aa99e50c88b945_revision_id"
  end

  create_table "graphemes_revisions_f772c1c8_c097_4911_b422_f10c0f166367", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_f772c1c8c0974911b422f10c0f166367_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_f772c1c8c0974911b422f10c0f166367_revision_id"
  end

  create_table "graphemes_revisions_f7d9d02b_a67e_466a_b077_620cb83e41c8", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_f7d9d02ba67e466ab077620cb83e41c8_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_f7d9d02ba67e466ab077620cb83e41c8_revision_id"
  end

  create_table "graphemes_revisions_f9e456eb_a79b_41e0_88da_5ebdc696807c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_f9e456eba79b41e088da5ebdc696807c_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_f9e456eba79b41e088da5ebdc696807c_revision_id"
  end

  create_table "graphemes_revisions_fa9e30a4_d6a7_4ecb_8eee_9036049459cb", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_fa9e30a4d6a74ecb8eee9036049459cb_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_fa9e30a4d6a74ecb8eee9036049459cb_revision_id"
  end

  create_table "graphemes_revisions_fb56a901_e410_4065_a8da_f7054965e00c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_fb56a901e4104065a8daf7054965e00c_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_fb56a901e4104065a8daf7054965e00c_revision_id"
  end

  create_table "graphemes_revisions_fb650044_866f_47d1_9b5b_3811b1d6241b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_fb650044866f47d19b5b3811b1d6241b_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_fb650044866f47d19b5b3811b1d6241b_revision_id"
  end

  create_table "graphemes_revisions_fd6ccede_e92f_4d38_a2a4_e53fba853e49", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_fd6ccedee92f4d38a2a4e53fba853e49_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_fd6ccedee92f4d38a2a4e53fba853e49_revision_id"
  end

  create_table "graphemes_revisions_ff04b664_75ce_41b2_a1ca_46ed29bf2a5c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_ff04b66475ce41b2a1ca46ed29bf2a5c_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_ff04b66475ce41b2a1ca46ed29bf2a5c_revision_id"
  end

  create_table "graphemes_revisions_ff55c8b2_4d03_4df2_a36a_7b9e1ce1322b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_ff55c8b24d034df2a36a7b9e1ce1322b_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_ff55c8b24d034df2a36a7b9e1ce1322b_revision_id"
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
