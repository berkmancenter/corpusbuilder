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

ActiveRecord::Schema.define(version: 20180129134830) do

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

  create_table "graphemes_revisions_022a9c55_9efb_45fa_8374_2da28864d370", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_022a9c559efb45fa83742da28864d370_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_022a9c559efb45fa83742da28864d370_revision_id"
  end

  create_table "graphemes_revisions_0786c133_e3d9_43a4_bbc0_b998cb53362e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_0786c133e3d943a4bbc0b998cb53362e_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_0786c133e3d943a4bbc0b998cb53362e_revision_id"
  end

  create_table "graphemes_revisions_08e5750d_6a30_4184_b651_5c4800557a72", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_08e5750d6a304184b6515c4800557a72_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_08e5750d6a304184b6515c4800557a72_revision_id"
  end

  create_table "graphemes_revisions_0d7a4dda_d319_4f78_b2b8_d8bd556f9767", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_0d7a4ddad3194f78b2b8d8bd556f9767_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_0d7a4ddad3194f78b2b8d8bd556f9767_revision_id"
  end

  create_table "graphemes_revisions_13555aea_64c7_4218_b589_ae3e9ac1cbcf", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_13555aea64c74218b589ae3e9ac1cbcf_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_13555aea64c74218b589ae3e9ac1cbcf_revision_id"
  end

  create_table "graphemes_revisions_15446f2e_d90f_4044_b4c1_2a2cfac60465", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_15446f2ed90f4044b4c12a2cfac60465_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_15446f2ed90f4044b4c12a2cfac60465_revision_id"
  end

  create_table "graphemes_revisions_17e2838b_35ee_4fcd_86cb_5a1928805d4a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_17e2838b35ee4fcd86cb5a1928805d4a_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_17e2838b35ee4fcd86cb5a1928805d4a_revision_id"
  end

  create_table "graphemes_revisions_18b80091_911c_43f7_9020_a4540c752186", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_18b80091911c43f79020a4540c752186_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_18b80091911c43f79020a4540c752186_revision_id"
  end

  create_table "graphemes_revisions_1cf5f5d4_72e2_4471_ac27_142531fb236a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_1cf5f5d472e24471ac27142531fb236a_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_1cf5f5d472e24471ac27142531fb236a_revision_id"
  end

  create_table "graphemes_revisions_221710d9_ab82_405b_b51b_2e6621fed9ad", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_221710d9ab82405bb51b2e6621fed9ad_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_221710d9ab82405bb51b2e6621fed9ad_revision_id"
  end

  create_table "graphemes_revisions_24c047fd_b0b0_4eec_86db_79b7828e9aa6", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_24c047fdb0b04eec86db79b7828e9aa6_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_24c047fdb0b04eec86db79b7828e9aa6_revision_id"
  end

  create_table "graphemes_revisions_24d16b2c_c1ba_47b6_b0d1_343587d6513a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_24d16b2cc1ba47b6b0d1343587d6513a_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_24d16b2cc1ba47b6b0d1343587d6513a_revision_id"
  end

  create_table "graphemes_revisions_28ac19b7_42a8_4a5c_87b4_604995ba1365", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_28ac19b742a84a5c87b4604995ba1365_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_28ac19b742a84a5c87b4604995ba1365_revision_id"
  end

  create_table "graphemes_revisions_2a19e493_446e_43c8_a9bc_3fd3f15a47ec", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_2a19e493446e43c8a9bc3fd3f15a47ec_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_2a19e493446e43c8a9bc3fd3f15a47ec_revision_id"
  end

  create_table "graphemes_revisions_2e5de497_8c81_45e6_917c_28262fd30bfa", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_2e5de4978c8145e6917c28262fd30bfa_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_2e5de4978c8145e6917c28262fd30bfa_revision_id"
  end

  create_table "graphemes_revisions_302306aa_ab4c_4dd2_824c_cc5667330113", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_302306aaab4c4dd2824ccc5667330113_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_302306aaab4c4dd2824ccc5667330113_revision_id"
  end

  create_table "graphemes_revisions_30bdeda8_df2f_450d_b54a_349df7cf00e4", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_30bdeda8df2f450db54a349df7cf00e4_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_30bdeda8df2f450db54a349df7cf00e4_revision_id"
  end

  create_table "graphemes_revisions_32ce4e74_d564_4b1a_ba90_a258dd4ba992", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_32ce4e74d5644b1aba90a258dd4ba992_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_32ce4e74d5644b1aba90a258dd4ba992_revision_id"
  end

  create_table "graphemes_revisions_3a679bf2_53fe_46d8_8b55_83ac952752fe", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_3a679bf253fe46d88b5583ac952752fe_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_3a679bf253fe46d88b5583ac952752fe_revision_id"
  end

  create_table "graphemes_revisions_3ab1b395_1be2_4a27_a8af_8925e89e6924", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_3ab1b3951be24a27a8af8925e89e6924_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_3ab1b3951be24a27a8af8925e89e6924_revision_id"
  end

  create_table "graphemes_revisions_3d5cd22a_742d_457f_8ad2_a5a22c4daf2e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_3d5cd22a742d457f8ad2a5a22c4daf2e_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_3d5cd22a742d457f8ad2a5a22c4daf2e_revision_id"
  end

  create_table "graphemes_revisions_40643d12_3baf_4e44_b7e2_fc67eeb2e5d8", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_40643d123baf4e44b7e2fc67eeb2e5d8_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_40643d123baf4e44b7e2fc67eeb2e5d8_revision_id"
  end

  create_table "graphemes_revisions_408a224e_f546_4858_9372_65e72f4f4934", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_408a224ef5464858937265e72f4f4934_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_408a224ef5464858937265e72f4f4934_revision_id"
  end

  create_table "graphemes_revisions_425034a7_bdad_498a_a988_99f0709d8a67", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_425034a7bdad498aa98899f0709d8a67_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_425034a7bdad498aa98899f0709d8a67_revision_id"
  end

  create_table "graphemes_revisions_455f1382_64fc_49ce_8dd4_39c789174aee", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_455f138264fc49ce8dd439c789174aee_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_455f138264fc49ce8dd439c789174aee_revision_id"
  end

  create_table "graphemes_revisions_4cac7249_452a_4b07_bcf0_306c7b59a493", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_4cac7249452a4b07bcf0306c7b59a493_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_4cac7249452a4b07bcf0306c7b59a493_revision_id"
  end

  create_table "graphemes_revisions_4e5de9d6_4b6d_42ec_bd7c_10f8ca45655c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_4e5de9d64b6d42ecbd7c10f8ca45655c_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_4e5de9d64b6d42ecbd7c10f8ca45655c_revision_id"
  end

  create_table "graphemes_revisions_4ec4ba20_59aa_4b86_a44e_ddb494fc590a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_4ec4ba2059aa4b86a44eddb494fc590a_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_4ec4ba2059aa4b86a44eddb494fc590a_revision_id"
  end

  create_table "graphemes_revisions_5323b933_7b7f_4c70_86f5_298506b8561d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_5323b9337b7f4c7086f5298506b8561d_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_5323b9337b7f4c7086f5298506b8561d_revision_id"
  end

  create_table "graphemes_revisions_5452bdc2_e96a_4f67_b3a4_c721608615c5", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_5452bdc2e96a4f67b3a4c721608615c5_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_5452bdc2e96a4f67b3a4c721608615c5_revision_id"
  end

  create_table "graphemes_revisions_5a6db931_cf15_4610_8e3a_43710dea3807", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_5a6db931cf1546108e3a43710dea3807_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_5a6db931cf1546108e3a43710dea3807_revision_id"
  end

  create_table "graphemes_revisions_5af3fe1d_80a2_4271_add8_ef49dbdd8e22", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_5af3fe1d80a24271add8ef49dbdd8e22_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_5af3fe1d80a24271add8ef49dbdd8e22_revision_id"
  end

  create_table "graphemes_revisions_5b308a4a_d9ba_4dc2_8482_8f8517a1d1d7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_5b308a4ad9ba4dc284828f8517a1d1d7_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_5b308a4ad9ba4dc284828f8517a1d1d7_revision_id"
  end

  create_table "graphemes_revisions_5c40e427_40db_4ba2_8e2f_dba2f2f3611e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_5c40e42740db4ba28e2fdba2f2f3611e_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_5c40e42740db4ba28e2fdba2f2f3611e_revision_id"
  end

  create_table "graphemes_revisions_65675dde_6a15_4aa9_8875_5b3c6f23de59", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_65675dde6a154aa988755b3c6f23de59_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_65675dde6a154aa988755b3c6f23de59_revision_id"
  end

  create_table "graphemes_revisions_66038b42_f4c5_4459_9358_2f3411edd918", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_66038b42f4c5445993582f3411edd918_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_66038b42f4c5445993582f3411edd918_revision_id"
  end

  create_table "graphemes_revisions_6f018a05_9613_4877_960a_c7da1cc0ab53", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_6f018a0596134877960ac7da1cc0ab53_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_6f018a0596134877960ac7da1cc0ab53_revision_id"
  end

  create_table "graphemes_revisions_7072a4cc_dd83_47cb_a471_edae7a6449fe", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_7072a4ccdd8347cba471edae7a6449fe_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_7072a4ccdd8347cba471edae7a6449fe_revision_id"
  end

  create_table "graphemes_revisions_7599eae7_f2f4_4838_87cd_1a17bd59093a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_7599eae7f2f4483887cd1a17bd59093a_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_7599eae7f2f4483887cd1a17bd59093a_revision_id"
  end

  create_table "graphemes_revisions_7c397eaa_5e09_4918_b058_aa9e0e3d5277", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_7c397eaa5e094918b058aa9e0e3d5277_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_7c397eaa5e094918b058aa9e0e3d5277_revision_id"
  end

  create_table "graphemes_revisions_8088dfa2_fdca_415f_a0c0_6738883b0f8e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_8088dfa2fdca415fa0c06738883b0f8e_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_8088dfa2fdca415fa0c06738883b0f8e_revision_id"
  end

  create_table "graphemes_revisions_894cf9f3_0741_451f_8ca4_6c12480bd42d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_894cf9f30741451f8ca46c12480bd42d_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_894cf9f30741451f8ca46c12480bd42d_revision_id"
  end

  create_table "graphemes_revisions_95f82b27_ce54_49b4_96f9_4834e5f3a707", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_95f82b27ce5449b496f94834e5f3a707_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_95f82b27ce5449b496f94834e5f3a707_revision_id"
  end

  create_table "graphemes_revisions_9b82cdb2_55f6_4125_a5c8_703949c55efe", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_9b82cdb255f64125a5c8703949c55efe_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_9b82cdb255f64125a5c8703949c55efe_revision_id"
  end

  create_table "graphemes_revisions_9be7ea46_a454_4075_91f9_b58fee78ce5e", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_9be7ea46a454407591f9b58fee78ce5e_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_9be7ea46a454407591f9b58fee78ce5e_revision_id"
  end

  create_table "graphemes_revisions_9d810d11_7a1b_4115_a507_d6039c46b131", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_9d810d117a1b4115a507d6039c46b131_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_9d810d117a1b4115a507d6039c46b131_revision_id"
  end

  create_table "graphemes_revisions_a87002b6_88b9_4d29_b539_93c026fd373a", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_a87002b688b94d29b53993c026fd373a_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_a87002b688b94d29b53993c026fd373a_revision_id"
  end

  create_table "graphemes_revisions_abe57e44_c0a4_4fb9_8155_43997bfb2421", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_abe57e44c0a44fb9815543997bfb2421_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_abe57e44c0a44fb9815543997bfb2421_revision_id"
  end

  create_table "graphemes_revisions_af26b45a_5fd8_4fa0_b31f_51f6cada7ee3", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_af26b45a5fd84fa0b31f51f6cada7ee3_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_af26b45a5fd84fa0b31f51f6cada7ee3_revision_id"
  end

  create_table "graphemes_revisions_afe32057_021c_4be6_95fa_b50efd2f84a4", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_afe32057021c4be695fab50efd2f84a4_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_afe32057021c4be695fab50efd2f84a4_revision_id"
  end

  create_table "graphemes_revisions_b34e9fd9_dfe2_46b5_9da2_ca2276754448", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_b34e9fd9dfe246b59da2ca2276754448_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_b34e9fd9dfe246b59da2ca2276754448_revision_id"
  end

  create_table "graphemes_revisions_b42c07af_0ac1_48ef_b165_59a9c78ae1c7", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_b42c07af0ac148efb16559a9c78ae1c7_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_b42c07af0ac148efb16559a9c78ae1c7_revision_id"
  end

  create_table "graphemes_revisions_bd3ea99a_7caf_4534_b406_9ceabecd3c19", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_bd3ea99a7caf4534b4069ceabecd3c19_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_bd3ea99a7caf4534b4069ceabecd3c19_revision_id"
  end

  create_table "graphemes_revisions_c12d34a0_74fb_4cb0_8cbe_f4aaed4561aa", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_c12d34a074fb4cb08cbef4aaed4561aa_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_c12d34a074fb4cb08cbef4aaed4561aa_revision_id"
  end

  create_table "graphemes_revisions_c531d92f_6521_4aae_8e28_7f577fb7042f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_c531d92f65214aae8e287f577fb7042f_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_c531d92f65214aae8e287f577fb7042f_revision_id"
  end

  create_table "graphemes_revisions_c8edbe86_345c_49f7_9a2a_e732daeff004", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_c8edbe86345c49f79a2ae732daeff004_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_c8edbe86345c49f79a2ae732daeff004_revision_id"
  end

  create_table "graphemes_revisions_cb1bd80c_68cf_4584_b28a_20617425d653", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_cb1bd80c68cf4584b28a20617425d653_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_cb1bd80c68cf4584b28a20617425d653_revision_id"
  end

  create_table "graphemes_revisions_d04fc1a4_e602_4b8f_8633_efe6894b950d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_d04fc1a4e6024b8f8633efe6894b950d_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_d04fc1a4e6024b8f8633efe6894b950d_revision_id"
  end

  create_table "graphemes_revisions_d1e0546c_4ab3_4c0b_a002_0c33b59e8961", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_d1e0546c4ab34c0ba0020c33b59e8961_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_d1e0546c4ab34c0ba0020c33b59e8961_revision_id"
  end

  create_table "graphemes_revisions_d53bc596_83b1_44e8_8902_e39edf14df8c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_d53bc59683b144e88902e39edf14df8c_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_d53bc59683b144e88902e39edf14df8c_revision_id"
  end

  create_table "graphemes_revisions_d58ddcbf_2371_437b_96fc_01dc68a04977", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_d58ddcbf2371437b96fc01dc68a04977_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_d58ddcbf2371437b96fc01dc68a04977_revision_id"
  end

  create_table "graphemes_revisions_d5a16416_9a8c_4f5a_8b2b_96af1a31c142", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_d5a164169a8c4f5a8b2b96af1a31c142_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_d5a164169a8c4f5a8b2b96af1a31c142_revision_id"
  end

  create_table "graphemes_revisions_d5be2e7a_fdf9_45e6_a3ed_44c8cb0f396f", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_d5be2e7afdf945e6a3ed44c8cb0f396f_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_d5be2e7afdf945e6a3ed44c8cb0f396f_revision_id"
  end

  create_table "graphemes_revisions_db4ae605_a455_4bf6_a0ca_2b4eca451e7b", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_db4ae605a4554bf6a0ca2b4eca451e7b_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_db4ae605a4554bf6a0ca2b4eca451e7b_revision_id"
  end

  create_table "graphemes_revisions_de5479e1_aac5_4d58_8faa_cd83bb9df9ba", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_de5479e1aac54d588faacd83bb9df9ba_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_de5479e1aac54d588faacd83bb9df9ba_revision_id"
  end

  create_table "graphemes_revisions_def9d8d4_0963_4b13_8b9d_ad18c019eb26", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_def9d8d409634b138b9dad18c019eb26_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_def9d8d409634b138b9dad18c019eb26_revision_id"
  end

  create_table "graphemes_revisions_eb1cf1e9_a5fd_44f2_85fb_49f9e53e9947", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_eb1cf1e9a5fd44f285fb49f9e53e9947_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_eb1cf1e9a5fd44f285fb49f9e53e9947_revision_id"
  end

  create_table "graphemes_revisions_ede093ae_0d9d_44f2_af17_c71f7c3cde32", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_ede093ae0d9d44f2af17c71f7c3cde32_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_ede093ae0d9d44f2af17c71f7c3cde32_revision_id"
  end

  create_table "graphemes_revisions_f1de5bc0_fca5_4220_8d3a_258f7268dc2c", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_f1de5bc0fca542208d3a258f7268dc2c_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_f1de5bc0fca542208d3a258f7268dc2c_revision_id"
  end

  create_table "graphemes_revisions_f79a5f3f_fe55_46d6_b706_e486a3773280", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_f79a5f3ffe5546d6b706e486a3773280_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_f79a5f3ffe5546d6b706e486a3773280_revision_id"
  end

  create_table "graphemes_revisions_fc6a2e3a_918f_4aad_a584_85c6c1ced721", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_fc6a2e3a918f4aada58485c6c1ced721_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_fc6a2e3a918f4aada58485c6c1ced721_revision_id"
  end

  create_table "graphemes_revisions_fe390252_9882_40dd_8977_acd589efb73d", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_fe390252988240dd8977acd589efb73d_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_fe390252988240dd8977acd589efb73d_revision_id"
  end

  create_table "graphemes_revisions_fecff4be_f96f_4f52_a6db_a281fb230e69", id: false, force: :cascade do |t|
    t.uuid "grapheme_id", null: false
    t.uuid "revision_id", null: false
    t.index ["grapheme_id", "revision_id"], name: "index_fecff4bef96f4f52a6dba281fb230e69_grapheme_id_revision_id"
    t.index ["revision_id"], name: "index_fecff4bef96f4f52a6dba281fb230e69_revision_id"
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
