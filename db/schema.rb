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

ActiveRecord::Schema.define(version: 20180313171908) do

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

  create_table "async_responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "payload"
    t.integer "status", default: 0
    t.uuid "editor_id"
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

  create_table "graphemes_revisions_003e2881_fdf9_48f3_9580_6d1d135c511e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_02350cdd_038e_4849_9858_4ae320b8f779", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_0d29c65e_6578_414f_94c8_7ec8d25cbff4", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_11c753b0_7816_4365_b511_e05f6b97e755", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_14c5e0fc_1674_4719_9616_b2a891391c24", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_2fac8132_24d0_481e_b166_96b2c3f60a4b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_2fbcfa80_5b85_4edd_aeca_3976fa4845dc", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_439647b6_ccef_4c45_8e65_80de0b32e7f2", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_4d11c0a3_899b_4339_852b_9ec2b1236fc9", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_4e66fbb8_0175_4244_8c5b_1b8a516e5424", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_51dd283d_1c0b_4bf6_9beb_b676ad3a968d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_584a49e5_3e5a_486f_8e54_585ce0288648", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_75dbdc4f_13b0_4945_a801_bf63317bb87d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_7b98d8d0_d833_41c6_8d24_22bfa640ccca", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_81e29a87_be46_4bba_9761_e5c71ed59b41", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_84cb1154_a382_4971_b153_749687220a22", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_855e6dec_8561_40a5_b9e4_f1015ce54786", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_86d45179_b87e_45ec_b53f_acb625d34bcc", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_879650d6_10bc_4566_a992_1b1272f80f92", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_92d1e62f_9bd1_45b3_8ef9_985e28c2bb25", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_a66c010e_594f_476c_9f88_8e8304aca3a9", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_c597aee0_f0e9_43e1_9914_f8499a6af344", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_ca55294a_0aee_4f83_adb5_85ca2b459065", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_cf8aad7f_a91f_4e84_b0e5_0cb47cc6148e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_d352858c_4ba1_4a62_89a9_3f6b17c3e88b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_dcdce719_6ea0_4544_a7ee_2d6b4d89564d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_ecff1aeb_5625_4754_b6b3_2324c0630985", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_f294b4e8_9448_4616_b209_6588ea4a5272", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_fa7bf967_459b_4c88_978d_ef90d14fa655", id: false, force: :cascade do |t|
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
