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

ActiveRecord::Schema[8.1].define(version: 2026_06_15_094102) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "locked_at", precision: nil
    t.string "locked_by"
    t.integer "priority", default: 0, null: false
    t.string "queue"
    t.datetime "run_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "external_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "email"
    t.datetime "updated_at", null: false
    t.index "lower(email)", name: "index_external_users_on_lowercase_email", unique: true
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.text "acronym"
    t.text "ancestry"
    t.integer "ancestry_depth", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.text "description"
    t.datetime "description_reminder_email_at", precision: nil
    t.integer "members_completion_score"
    t.text "name"
    t.string "slug"
    t.datetime "updated_at", precision: nil
    t.index "lower(name) gin_trgm_ops", name: "index_groups_on_name_trgm", using: :gin
    t.index ["ancestry"], name: "index_groups_on_ancestry"
    t.index ["slug"], name: "index_groups_on_slug"
  end

  create_table "memberships", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "group_id", null: false
    t.boolean "leader", default: false
    t.integer "person_id", null: false
    t.text "role"
    t.boolean "subscribed", default: true, null: false
    t.datetime "updated_at", precision: nil
    t.index ["group_id"], name: "index_memberships_on_group_id"
    t.index ["person_id"], name: "index_memberships_on_person_id"
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.text "building"
    t.text "city"
    t.datetime "created_at", precision: nil
    t.string "current_project"
    t.text "description"
    t.text "email"
    t.text "given_name"
    t.string "image"
    t.datetime "last_login_at", precision: nil
    t.datetime "last_reminder_email_at", precision: nil
    t.text "location_in_building"
    t.integer "login_count", default: 0, null: false
    t.text "pager_number"
    t.text "primary_phone_number"
    t.integer "profile_photo_id"
    t.text "secondary_email"
    t.text "secondary_phone_number"
    t.string "slug"
    t.boolean "super_admin", default: false
    t.text "surname"
    t.boolean "swap_email_display"
    t.datetime "updated_at", precision: nil
    t.boolean "works_friday", default: true
    t.boolean "works_monday", default: true
    t.boolean "works_saturday", default: false
    t.boolean "works_sunday", default: false
    t.boolean "works_thursday", default: true
    t.boolean "works_tuesday", default: true
    t.boolean "works_wednesday", default: true
    t.index "lower((current_project)::text) gin_trgm_ops", name: "index_people_on_current_project_trgm", where: "(current_project IS NOT NULL)", using: :gin
    t.index "lower(email)", name: "index_people_on_lowercase_email", unique: true
    t.index "lower(given_name) gin_trgm_ops", name: "index_people_on_given_name_trgm", using: :gin
    t.index "lower(surname) gin_trgm_ops", name: "index_people_on_surname_trgm", using: :gin
    t.index ["slug"], name: "index_people_on_slug", unique: true
  end

  create_table "permitted_domains", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "domain"
    t.datetime "updated_at", precision: nil
  end

  create_table "profile_photos", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "image"
    t.datetime "updated_at", precision: nil
  end

  create_table "queued_notifications", id: :serial, force: :cascade do |t|
    t.text "changes_json"
    t.datetime "created_at", precision: nil, null: false
    t.integer "current_user_id"
    t.boolean "edit_finalised", default: false
    t.string "email_template"
    t.integer "person_id"
    t.datetime "processing_started_at", precision: nil
    t.boolean "sent", default: false
    t.string "session_id"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", precision: nil, null: false
    t.string "extension"
    t.string "mime_type"
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "tokens", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.boolean "spent", default: false
    t.datetime "updated_at", precision: nil
    t.text "user_email"
    t.text "value"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "event", null: false
    t.string "ip_address"
    t.integer "item_id", null: false
    t.text "item_type", null: false
    t.text "object"
    t.text "object_changes"
    t.string "user_agent"
    t.text "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "memberships", "groups"
  add_foreign_key "memberships", "people"
end
