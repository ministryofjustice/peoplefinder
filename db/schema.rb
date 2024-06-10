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

ActiveRecord::Schema[7.1].define(version: 2024_05_23_135243) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "external_users", force: :cascade do |t|
    t.text "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower(email)", name: "index_external_users_on_lowercase_email", unique: true
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "slug"
    t.text "description"
    t.text "ancestry"
    t.integer "ancestry_depth", default: 0, null: false
    t.text "acronym"
    t.datetime "description_reminder_email_at", precision: nil
    t.integer "members_completion_score"
    t.index ["ancestry"], name: "index_groups_on_ancestry"
    t.index ["slug"], name: "index_groups_on_slug"
  end

  create_table "memberships", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "person_id", null: false
    t.text "role"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "leader", default: false
    t.boolean "subscribed", default: true, null: false
    t.index ["group_id"], name: "index_memberships_on_group_id"
    t.index ["person_id"], name: "index_memberships_on_person_id"
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.text "given_name"
    t.text "surname"
    t.text "email"
    t.text "primary_phone_number"
    t.text "secondary_phone_number"
    t.text "location_in_building"
    t.text "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "works_monday", default: true
    t.boolean "works_tuesday", default: true
    t.boolean "works_wednesday", default: true
    t.boolean "works_thursday", default: true
    t.boolean "works_friday", default: true
    t.string "image"
    t.string "slug"
    t.boolean "works_saturday", default: false
    t.boolean "works_sunday", default: false
    t.integer "login_count", default: 0, null: false
    t.datetime "last_login_at", precision: nil
    t.boolean "super_admin", default: false
    t.text "building"
    t.text "city"
    t.text "secondary_email"
    t.integer "profile_photo_id"
    t.datetime "last_reminder_email_at", precision: nil
    t.string "current_project"
    t.text "pager_number"
    t.boolean "swap_email_display"
    t.index "lower(email)", name: "index_people_on_lowercase_email", unique: true
    t.index ["slug"], name: "index_people_on_slug", unique: true
  end

  create_table "permitted_domains", id: :serial, force: :cascade do |t|
    t.string "domain"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "profile_photos", id: :serial, force: :cascade do |t|
    t.string "image"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "queued_notifications", id: :serial, force: :cascade do |t|
    t.string "email_template"
    t.string "session_id"
    t.integer "person_id"
    t.integer "current_user_id"
    t.text "changes_json"
    t.boolean "edit_finalised", default: false
    t.datetime "processing_started_at", precision: nil
    t.boolean "sent", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.text "content"
    t.string "name"
    t.string "extension"
    t.string "mime_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "tokens", id: :serial, force: :cascade do |t|
    t.text "value"
    t.text "user_email"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "spent", default: false
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.text "item_type", null: false
    t.integer "item_id", null: false
    t.text "event", null: false
    t.text "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil
    t.text "object_changes"
    t.string "ip_address"
    t.string "user_agent"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "memberships", "groups"
  add_foreign_key "memberships", "people"
end
