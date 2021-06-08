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

ActiveRecord::Schema.define(version: 2021_06_07_100053) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "ams_subjects", force: :cascade do |t|
    t.string "code"
    t.string "title"
    t.bigint "subject_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["subject_id"], name: "index_ams_subjects_on_subject_id"
  end

  create_table "answers", force: :cascade do |t|
    t.bigint "proposal_field_id", null: false
    t.bigint "proposal_id", null: false
    t.string "answer"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["proposal_field_id"], name: "index_answers_on_proposal_field_id"
    t.index ["proposal_id"], name: "index_answers_on_proposal_id"
  end

  create_table "column_to_proposals", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "demographic_data", force: :cascade do |t|
    t.jsonb "result", default: "{}", null: false
    t.bigint "person_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["person_id"], name: "index_demographic_data_on_person_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string "content"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "invites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "email"
    t.string "invited_as"
    t.integer "status", default: 0
    t.integer "response", default: 0
    t.bigint "proposal_id", null: false
    t.bigint "person_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deadline_date"
    t.index ["person_id"], name: "index_invites_on_person_id"
    t.index ["proposal_id"], name: "index_invites_on_proposal_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "code"
    t.string "city"
    t.string "country"
  end

  create_table "options", force: :cascade do |t|
    t.string "text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "index"
    t.string "value"
    t.bigint "proposal_field_id", null: false
    t.index ["proposal_field_id"], name: "index_options_on_proposal_field_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "email"
    t.string "affiliation"
    t.jsonb "subject"
    t.jsonb "research_areas"
    t.text "biography"
    t.boolean "deceased"
    t.boolean "retired"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
    t.string "url"
  end

  create_table "proposal_fields", force: :cascade do |t|
    t.string "statement"
    t.bigint "proposal_form_id", null: false
    t.integer "location_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "position"
    t.text "description"
    t.bigint "fieldable_id"
    t.string "fieldable_type"
    t.string "guideline_link"
    t.index ["fieldable_type", "fieldable_id"], name: "index_proposal_fields_on_fieldable_type_and_fieldable_id"
    t.index ["proposal_form_id"], name: "index_proposal_fields_on_proposal_form_id"
  end

  create_table "proposal_fields_dates", force: :cascade do |t|
    t.string "statement"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "proposal_fields_multi_choices", force: :cascade do |t|
    t.string "statement"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "proposal_fields_radios", force: :cascade do |t|
    t.string "statement"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "proposal_fields_single_choices", force: :cascade do |t|
    t.string "statement"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "proposal_fields_texts", force: :cascade do |t|
    t.string "statement"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "proposal_forms", force: :cascade do |t|
    t.integer "status"
    t.bigint "proposal_type_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.string "title"
    t.integer "version", default: 0
    t.text "introduction"
    t.integer "version", default: 0
    t.index ["created_by_id"], name: "index_proposal_forms_on_created_by_id"
    t.index ["proposal_type_id"], name: "index_proposal_forms_on_proposal_type_id"
    t.index ["updated_by_id"], name: "index_proposal_forms_on_updated_by_id"
  end

  create_table "proposal_locations", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.bigint "proposal_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["location_id"], name: "index_proposal_locations_on_location_id"
    t.index ["proposal_id"], name: "index_proposal_locations_on_proposal_id"
  end

  create_table "proposal_roles", force: :cascade do |t|
    t.bigint "proposal_id", null: false
    t.bigint "role_id", null: false
    t.bigint "person_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["person_id"], name: "index_proposal_roles_on_person_id"
    t.index ["proposal_id"], name: "index_proposal_roles_on_proposal_id"
    t.index ["role_id"], name: "index_proposal_roles_on_role_id"
  end

  create_table "proposal_type_locations", force: :cascade do |t|
    t.bigint "proposal_type_id", null: false
    t.bigint "location_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["location_id"], name: "index_proposal_type_locations_on_location_id"
    t.index ["proposal_type_id"], name: "index_proposal_type_locations_on_proposal_type_id"
  end

  create_table "proposal_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "year"
  end

  create_table "proposals", force: :cascade do |t|
    t.bigint "proposal_type_id", null: false
    t.jsonb "submission"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status"
    t.string "title"
    t.string "year"
    t.bigint "proposal_form_id"
    t.index ["proposal_form_id"], name: "index_proposals_on_proposal_form_id"
    t.index ["proposal_type_id"], name: "index_proposals_on_proposal_type_id"
  end

  create_table "role_privileges", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.string "privilege_name"
    t.string "permission_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["role_id"], name: "index_role_privileges_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "subject_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "subjects", force: :cascade do |t|
    t.string "code"
    t.string "title"
    t.bigint "subject_category_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_subjects_on_code", unique: true
    t.index ["subject_category_id"], name: "index_subjects_on_subject_category_id"
  end

  create_table "survey_answers", force: :cascade do |t|
    t.string "answer"
    t.bigint "person_id", null: false
    t.bigint "survey_id", null: false
    t.bigint "survey_question_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["person_id"], name: "index_survey_answers_on_person_id"
    t.index ["survey_id"], name: "index_survey_answers_on_survey_id"
    t.index ["survey_question_id"], name: "index_survey_answers_on_survey_question_id"
  end

  create_table "survey_questions", force: :cascade do |t|
    t.string "statement"
    t.jsonb "options", default: "{}", null: false
    t.integer "select", default: 0
    t.bigint "survey_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["survey_id"], name: "index_survey_questions_on_survey_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.string "introduction"
    t.string "disclaimer"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "validations", force: :cascade do |t|
    t.integer "validation_type"
    t.string "value"
    t.string "error_message"
    t.bigint "proposal_field_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["proposal_field_id"], name: "index_validations_on_proposal_field_id"
  end

  add_foreign_key "ams_subjects", "subjects"
  add_foreign_key "answers", "proposal_fields"
  add_foreign_key "answers", "proposals"
  add_foreign_key "demographic_data", "people"
  add_foreign_key "invites", "people"
  add_foreign_key "invites", "proposals"
  add_foreign_key "options", "proposal_fields"
  add_foreign_key "proposal_fields", "proposal_forms"
  add_foreign_key "proposal_forms", "proposal_types"
  add_foreign_key "proposal_forms", "users", column: "created_by_id"
  add_foreign_key "proposal_forms", "users", column: "updated_by_id"
  add_foreign_key "proposal_locations", "locations"
  add_foreign_key "proposal_locations", "proposals"
  add_foreign_key "proposal_roles", "people"
  add_foreign_key "proposal_roles", "proposals"
  add_foreign_key "proposal_roles", "roles"
  add_foreign_key "proposal_type_locations", "locations"
  add_foreign_key "proposal_type_locations", "proposal_types"
  add_foreign_key "proposals", "proposal_forms"
  add_foreign_key "proposals", "proposal_types"
  add_foreign_key "role_privileges", "roles"
  add_foreign_key "subjects", "subject_categories"
  add_foreign_key "survey_answers", "people"
  add_foreign_key "survey_answers", "survey_questions"
  add_foreign_key "survey_answers", "surveys"
  add_foreign_key "survey_questions", "surveys"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
