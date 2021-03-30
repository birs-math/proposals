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

ActiveRecord::Schema.define(version: 2021_03_30_131454) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "engagements", force: :cascade do |t|
    t.string "year"
    t.integer "proposal_submission"
    t.string "engagementable_type"
    t.bigint "engagementable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["engagementable_type", "engagementable_id"], name: "index_engagements_on_engagementable"
  end

  create_table "location_proposal_types", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.bigint "proposal_type_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["location_id"], name: "index_location_proposal_types_on_location_id"
    t.index ["proposal_type_id"], name: "index_location_proposal_types_on_proposal_type_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "people", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "affiliation"
    t.jsonb "subject"
    t.jsonb "areas_of_expertise"
    t.text "biography"
    t.boolean "deceased"
    t.boolean "retired"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "proposal_answers", force: :cascade do |t|
    t.bigint "proposal_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["proposal_id"], name: "index_proposal_answers_on_proposal_id"
  end

  create_table "proposal_forms", force: :cascade do |t|
    t.bigint "proposal_type_id", null: false
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["proposal_type_id"], name: "index_proposal_forms_on_proposal_type_id"
  end

  create_table "proposal_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "proposals", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.bigint "proposal_type_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["location_id"], name: "index_proposals_on_location_id"
    t.index ["proposal_type_id"], name: "index_proposals_on_proposal_type_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "type"
    t.string "statement"
    t.bigint "proposal_form_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["proposal_form_id"], name: "index_questions_on_proposal_form_id"
  end

  create_table "research_groups", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "researches", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "workshops", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "location_proposal_types", "locations"
  add_foreign_key "location_proposal_types", "proposal_types"
  add_foreign_key "proposal_answers", "proposals"
  add_foreign_key "proposal_forms", "proposal_types"
  add_foreign_key "proposals", "locations"
  add_foreign_key "proposals", "proposal_types"
  add_foreign_key "questions", "proposal_forms"
end
