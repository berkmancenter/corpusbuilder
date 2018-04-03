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

ActiveRecord::Schema.define(version: 20180403155425) do

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
    t.integer "surface_number"
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
    t.index ["zone_id"], name: "graphemes_zone_id"
  end

  create_table "graphemes_revisions_003e2881_fdf9_48f3_9580_6d1d135c511e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_02350cdd_038e_4849_9858_4ae320b8f779", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_05455ec8_5051_466f_ac1d_b78b5c3e3270", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_0600e747_ec2f_4555_a1a0_bc46c8014957", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_0681c7f2_e755_4f95_bd85_7fab2459fb59", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_0d29c65e_6578_414f_94c8_7ec8d25cbff4", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_11bfcadc_ab79_4a60_ba8f_79d9c3ebc6da", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_11c753b0_7816_4365_b511_e05f6b97e755", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_11cd3300_5799_4815_afe9_6f83b6423038", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_11decc4c_2f99_41d8_b7ca_a15d0c163f38", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_1358501a_7bcc_44e6_b90a_f17deb1d0b86", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_1381fa68_60fb_429a_8557_936b16dd17c8", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_139cfa8e_7c73_4967_a237_ae17be15ea00", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_13be5645_6346_4187_9803_2d8fa2257ebb", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_14c5e0fc_1674_4719_9616_b2a891391c24", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_14d80b43_5c66_45bb_8132_ee2c8c6f7dc6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_17347bf2_d8de_4626_be0b_99d43f7c2c98", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_18a08b6f_3178_4656_8a56_c4af008f1cf8", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_19086f74_32d1_4f9d_bc14_e87adec90a6f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_1b0888e2_8569_4f72_8c8f_f3d8372c8832", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_22db67bd_d465_44ee_852e_2dbd6f73147a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_23107d6b_73b9_4572_8936_c8bd9ab025a3", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_23eab3ee_faa4_40fd_9631_2de3cc95d243", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_23fda9ba_73d6_49f6_80c0_4733efb2de18", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_2b174603_815b_4131_a7bd_9785eeb5e648", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_2d781aa0_7dea_4be4_80c6_aa037ab0177d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_2fac8132_24d0_481e_b166_96b2c3f60a4b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_2fbcfa80_5b85_4edd_aeca_3976fa4845dc", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_3555e871_cf13_4fdf_9d33_0de4430e47dc", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_3757882b_a551_41b2_a81d_0a207983d9ac", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_3ca5b4f3_a8af_495d_ba59_6aceefb582a2", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_3cf6dd32_759e_43e2_9679_dfa44516fded", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_3efe0d4d_8fdf_4189_bdf3_a42b90b87ce8", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_40b2207b_fd7e_4f32_a4fb_eb490d143cb7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_41582c0e_48af_43ef_9a03_eac59fcea06b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_439647b6_ccef_4c45_8e65_80de0b32e7f2", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_4547bd0a_976d_41c9_b6e1_30d2d06a08ec", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_4bacca51_8da5_4c20_81a1_60dd295c08fd", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_4c324dae_55dc_44f1_b87d_38f065d393dc", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_4d11c0a3_899b_4339_852b_9ec2b1236fc9", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_4d9ead15_7064_4e1e_b801_dfb465cab21f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_4e66fbb8_0175_4244_8c5b_1b8a516e5424", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_51dd283d_1c0b_4bf6_9beb_b676ad3a968d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_51f05eac_d2da_42b2_ae6b_9e63936394dc", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_52bab2c0_dec3_4b00_97c2_b40c30a64c84", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_56fc39c7_fd6f_4c17_b1fa_dba2e559717e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_584a49e5_3e5a_486f_8e54_585ce0288648", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_587cee29_a90c_4b76_bee8_83447289df4a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_599ed1cd_f4ef_4ecc_9f0d_5b61cd3bc796", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_59bb5f10_58c9_4474_a902_5c7692a928cd", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_5ab33ff0_ccd1_4b64_bf0a_e37567a45bb0", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_5febdd3b_1f50_4a8a_8ce6_2c317543021f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_63e35aec_2764_4890_98d2_1b0644128499", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_691388c3_5148_4be6_95fb_723311a52c40", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_69f285ec_38e0_4162_a08d_f242de808b22", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_6d09275a_aa2d_4a4a_a52d_fbf4531e6842", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_6e32d0b8_af9e_46b2_a2d0_af7f66997a89", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_729af2d0_5ab4_4c50_8c24_afc4d50d23d2", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_75dbdc4f_13b0_4945_a801_bf63317bb87d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_76415ce3_c181_41ff_a9c0_1bc9d1025a16", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_7866db10_0ee3_4aa3_8c8e_a19343a5aacb", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_793ee7ff_3349_4589_8d20_34cf63374d1e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_7971afa8_ea85_4eab_b39f_1e977f60974a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_7b1f2c56_bb47_45ba_8f47_4da81e16e640", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_7b98d8d0_d833_41c6_8d24_22bfa640ccca", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_7eb418d6_07b8_434e_ae61_c23fb254baad", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_7f0df5ea_b505_4e52_9b06_86194102569b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_7f5d711f_5cf7_4523_b900_c50a08cae882", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_81e29a87_be46_4bba_9761_e5c71ed59b41", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_83126e57_7439_4eda_bdd9_59750b1dc9a6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_8402905b_116f_4dd1_8aaa_1607bc8d86f7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_84cb1154_a382_4971_b153_749687220a22", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_855e6dec_8561_40a5_b9e4_f1015ce54786", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_85eea9e0_87a6_4767_a3f2_4acfd5cbe959", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_86333c7a_5447_4700_9d8b_5051ad18d30d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_86d45179_b87e_45ec_b53f_acb625d34bcc", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_879650d6_10bc_4566_a992_1b1272f80f92", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_8839e9cc_e52d_4dd9_b8ad_9f5fad00d4be", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_8c6a5e2e_2dbf_460a_a9ca_991b96c96b87", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_8fc38844_7c2b_4845_bb1f_741e51688549", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_8fe3f683_6ebe_4d36_aed1_4ddd972bdf9d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_910c1fc6_1c4c_4d03_83ec_3124f00daa95", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_92d1e62f_9bd1_45b3_8ef9_985e28c2bb25", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_94811bcc_c104_42a9_944f_8e7267907cf8", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_94c1acc9_4de3_4a3e_b402_523fa99bd0ca", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_952f7d32_bc1c_4200_a9d8_b1c653ff0a90", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_95f29ee0_ff7b_471a_86e8_a7b9818230bd", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_9e407b86_7a59_41a6_a9df_c80eea84b280", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_9fcaed6c_a241_4ea0_b5ac_05442968de91", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_a14fa79f_1a35_4bcc_b7f6_8deb13df9314", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_a2a5e2e0_d234_4686_aa2c_3cd7b832164a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_a66c010e_594f_476c_9f88_8e8304aca3a9", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_a8b2f595_6c75_4dc2_b98f_5c72b72ab1aa", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_ac8cc85d_4d7c_47bf_a2bc_33a2a7c52228", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_af179761_ca13_467e_a7f7_726c713e2cf4", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_af8385cd_0360_4301_baea_422ba5c53cdf", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_b0fce48a_5248_4bea_a1de_c19dfa8bd1c8", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_b34f4cad_97ad_455e_9d3e_ca48ad123ada", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_b3be1d51_bd14_4dd8_88f3_0011ea1a1177", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_b4cf8bb1_e103_4a22_950c_9fd26ee91f0a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_b539e708_a9b3_489e_b6ae_c830a3a68650", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_b8b50d5b_b224_41ad_b43a_818e163e1680", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_bc80d99c_de91_40c5_b568_463b925a3769", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_be339f55_2f8e_45b6_8d82_fee707f6e394", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_c264a1ad_9cae_4bc3_b338_2432de9f1130", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_c597aee0_f0e9_43e1_9914_f8499a6af344", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_c61ef3af_ae51_4a01_977f_ac67e56a72f6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_c8433595_f4cd_4aea_80bc_53f683d131ad", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_ca55294a_0aee_4f83_adb5_85ca2b459065", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_cc374ba5_452a_4c01_aaa7_c49e21b1fc1c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_cf46c771_15e5_40d4_a01d_3153d172b0bf", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_cf8aad7f_a91f_4e84_b0e5_0cb47cc6148e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_d0c8e65d_e2ae_4215_a5a4_8f40ea0d4975", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_d352858c_4ba1_4a62_89a9_3f6b17c3e88b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_d4293351_deef_4d5c_b0f5_f3162560145c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_d8e53945_84e1_48f1_9d49_bad3d6852461", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_da7422ad_d58f_47eb_8b81_bf9e7807dfa1", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_dc280906_a499_41a5_8779_f334eb7bb754", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_dcdce719_6ea0_4544_a7ee_2d6b4d89564d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_dd6779bf_0e27_487a_b1b3_fc9d5cb68cc0", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_df6a654e_02ab_400d_979c_3cd77884b6ac", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_dfa28d79_0306_48eb_beae_73cce01c7e74", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_e44b1373_d6da_44eb_86bf_5c16295ba01b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_ebf83613_3409_41f7_9687_d1232dd2c7f8", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_ecf28fb4_aa89_4241_8b3f_ed1a8553b7a7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_ecff1aeb_5625_4754_b6b3_2324c0630985", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_ed22a294_aaeb_4b02_be30_7c634de10ce0", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_ed3052b6_3163_4850_b8f4_9bd64b319dba", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_edda95bf_8e96_4672_b2fa_7b2c33b6f38e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_f294b4e8_9448_4616_b209_6588ea4a5272", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_f41b517c_1ea6_48fb_9067_abaa0403a137", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_fa7bf967_459b_4c88_978d_ef90d14fa655", id: false, force: :cascade do |t|
    t.uuid "grapheme_id"
  end

  create_table "graphemes_revisions_fc91a7c5_74eb_41e3_bdb0_a200d535b21c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
  end

  create_table "graphemes_revisions_ff4c2b29_8678_42a6_8b17_2137208148dc", id: false, force: :cascade do |t|
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
    t.index ["surface_id"], name: "zones_surface_id"
  end

end
