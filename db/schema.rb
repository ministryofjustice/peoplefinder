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

ActiveRecord::Schema.define(version: 20140620134259) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "groups", force: true do |t|
    t.integer  "parent_id"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.text     "description"
    t.datetime "deleted_at"
  end

  add_index "groups", ["deleted_at"], name: "index_groups_on_deleted_at", using: :btree
  add_index "groups", ["parent_id"], name: "index_groups_on_parent_id", using: :btree
  add_index "groups", ["slug"], name: "index_groups_on_slug", unique: true, using: :btree

  create_table "memberships", force: true do |t|
    t.integer  "group_id"
    t.integer  "person_id"
    t.text     "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "leader",     default: false
    t.datetime "deleted_at"
  end

  add_index "memberships", ["deleted_at"], name: "index_memberships_on_deleted_at", using: :btree
  add_index "memberships", ["group_id"], name: "index_memberships_on_group_id", using: :btree
  add_index "memberships", ["person_id"], name: "index_memberships_on_person_id", using: :btree

  create_table "people", force: true do |t|
    t.text     "given_name"
    t.text     "surname"
    t.text     "email"
    t.text     "phone"
    t.text     "mobile"
    t.text     "location"
    t.text     "keywords"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "works_monday",    default: true
    t.boolean  "works_tuesday",   default: true
    t.boolean  "works_wednesday", default: true
    t.boolean  "works_thursday",  default: true
    t.boolean  "works_friday",    default: true
    t.datetime "deleted_at"
  end

  add_index "people", ["deleted_at"], name: "index_people_on_deleted_at", using: :btree

  create_table "versions", force: true do |t|
    t.text     "item_type",      null: false
    t.integer  "item_id",        null: false
    t.text     "event",          null: false
    t.text     "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
