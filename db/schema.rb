# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170228181641) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "groups", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.text     "description"
    t.text     "ancestry"
    t.integer  "ancestry_depth",                default: 0, null: false
    t.text     "acronym"
    t.datetime "description_reminder_email_at"
    t.integer  "members_completion_score"
  end

  add_index "groups", ["ancestry"], name: "index_groups_on_ancestry", using: :btree
  add_index "groups", ["slug"], name: "index_groups_on_slug", using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer  "group_id",                   null: false
    t.integer  "person_id",                  null: false
    t.text     "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "leader",     default: false
    t.boolean  "subscribed", default: true,  null: false
  end

  add_index "memberships", ["group_id"], name: "index_memberships_on_group_id", using: :btree
  add_index "memberships", ["person_id"], name: "index_memberships_on_person_id", using: :btree

  create_table "people", force: :cascade do |t|
    t.text     "given_name"
    t.text     "surname"
    t.text     "email"
    t.text     "primary_phone_number"
    t.text     "secondary_phone_number"
    t.text     "location_in_building"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "works_monday",           default: true
    t.boolean  "works_tuesday",          default: true
    t.boolean  "works_wednesday",        default: true
    t.boolean  "works_thursday",         default: true
    t.boolean  "works_friday",           default: true
    t.string   "image"
    t.string   "slug"
    t.boolean  "works_saturday",         default: false
    t.boolean  "works_sunday",           default: false
    t.integer  "login_count",            default: 0,     null: false
    t.datetime "last_login_at"
    t.boolean  "super_admin",            default: false
    t.text     "building"
    t.text     "city"
    t.text     "secondary_email"
    t.integer  "profile_photo_id"
    t.datetime "last_reminder_email_at"
    t.string   "current_project"
    t.text     "pager_number"
    t.boolean  "prototype",              default: false
    t.boolean  "creation_completed",     default: true
  end

  add_index "people", ["slug"], name: "index_people_on_slug", unique: true, using: :btree

  create_table "permitted_domains", force: :cascade do |t|
    t.string   "domain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profile_photos", force: :cascade do |t|
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", force: :cascade do |t|
    t.text     "content"
    t.string   "name"
    t.string   "extension"
    t.string   "mime_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "queued_notifications", force: :cascade do |t|
    t.string   "email_template"
    t.string   "session_id"
    t.integer  "person_id"
    t.integer  "current_user_id"
    t.text     "changes_json"
    t.boolean  "edit_finalised",        default: false
    t.datetime "processing_started_at"
    t.boolean  "sent",                  default: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "tokens", force: :cascade do |t|
    t.text     "value"
    t.text     "user_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "spent",      default: false
  end

  create_table "versions", force: :cascade do |t|
    t.text     "item_type",      null: false
    t.integer  "item_id",        null: false
    t.text     "event",          null: false
    t.text     "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.string   "ip_address"
    t.string   "user_agent"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  add_foreign_key "memberships", "groups"
  add_foreign_key "memberships", "people"
end
